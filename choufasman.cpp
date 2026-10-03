#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

/* ==================== 1. Parameters and Data Structures ==================== */

// Single-letter codes for the 20 standard amino acids
const char AA_ORDER[] = "ACDEFGHIKLMNPQRSTVWY";
#define NUM_AA 20

// Chou-Fasman parameter table: [P(a) helix, P(b) sheet, P(t) turn, f(i), f(i+1), f(i+2), f(i+3)]
// Data source: classic Chou & Fasman (1978) literature table
const double PARAMS[NUM_AA][7] = {
    {1.42, 0.83, 0.66, 0.060, 0.076, 0.035, 0.058}, // A
    {0.70, 1.19, 1.19, 0.149, 0.050, 0.117, 0.128}, // C
    {1.01, 0.54, 1.46, 0.147, 0.110, 0.179, 0.081}, // D
    {1.51, 0.37, 0.74, 0.056, 0.060, 0.077, 0.064}, // E
    {1.13, 1.38, 0.60, 0.059, 0.041, 0.065, 0.065}, // F
    {0.57, 0.75, 1.56, 0.102, 0.085, 0.190, 0.152}, // G
    {1.00, 0.87, 0.95, 0.140, 0.047, 0.093, 0.054}, // H
    {1.08, 1.60, 0.47, 0.043, 0.034, 0.013, 0.056}, // I
    {1.21, 1.30, 0.59, 0.061, 0.025, 0.036, 0.070}, // K
    {1.41, 1.30, 0.59, 0.061, 0.025, 0.036, 0.070}, // L
    {1.45, 1.05, 0.60, 0.068, 0.082, 0.014, 0.055}, // M
    {0.67, 0.89, 1.56, 0.161, 0.083, 0.191, 0.091}, // N
    {0.57, 0.55, 1.52, 0.102, 0.301, 0.034, 0.068}, // P
    {1.11, 1.10, 0.98, 0.074, 0.098, 0.037, 0.098}, // Q
    {0.98, 0.93, 0.95, 0.070, 0.106, 0.099, 0.085}, // R
    {0.77, 0.75, 1.43, 0.120, 0.139, 0.125, 0.106}, // S
    {0.83, 1.19, 0.96, 0.086, 0.108, 0.065, 0.079}, // T
    {1.06, 1.70, 0.50, 0.0,   0.0,   0.0,   0.0  }, // V
    {1.08, 1.37, 0.96, 0.0,   0.0,   0.0,   0.0  }, // W
    {0.69, 1.47, 1.14, 0.0,   0.0,   0.0,   0.0  }  // Y
};

// Secondary structure type enumeration
typedef enum { COIL, HELIX, SHEET, TURN } SS_Type;

// Algorithm threshold constants
#define P_HELIX_NUCLEATE 1.03
#define P_SHEET_NUCLEATE 1.00
#define P_EXTEND         1.00
#define P_HELIX_EXTEND   1.03
#define P_SHEET_EXTEND   1.05
#define P_TURN_CUTOFF    0.000075
#define P_TURN_AVG       1.00

/* ==================== 2. Helper Functions ==================== */

int get_aa_index(char aa) {
    int i;
    for (i = 0; i < NUM_AA; i++) {
        if (AA_ORDER[i] == aa) return i;
    }
    return -1;
}

double get_propensity(char aa, int type) {
    int idx = get_aa_index(aa);
    if (idx == -1) return 0.0;
    if (type < 0 || type > 2) return 0.0;
    return PARAMS[idx][type];
}

/* ==================== 3. Core Prediction Function ==================== */

void predict_chou_fasman(const char* seq, int len, SS_Type* ss) {
    int i, k, start, end, seg_len, has_pro, count, occupied;
    double sum, sum_a, sum_b, avg_a, avg_b, avg_pt, avg_pa, avg_pb;
    double pt_product, pt_sum, pa_sum, pb_sum;
    int* assigned;

    // Initialize all residues as coil (C)
    for (i = 0; i < len; i++) {
        ss[i] = COIL;
    }

    // Dynamically allocate the assigned array (replaces variable-length array)
    assigned = (int*)malloc(sizeof(int) * len);
    if (assigned == NULL) {
        return;
    }
    memset(assigned, 0, sizeof(int) * len);

    /* --- Step 1: Predict Alpha helix --- */
    for (i = 0; i <= len - 6; i++) {
        count = 0;
        for (k = 0; k < 6; k++) {
            if (get_propensity(seq[i+k], 0) > 1.0) count++;
        }
        if (count >= 4) {
            start = i;
            end = i + 5;

            // Extend to the left
            while (start > 0) {
                sum = 0.0;
                for (k = 0; k < 4; k++) {
                    if (start - 1 + k >= 0 && start - 1 + k < len) {
                        sum += get_propensity(seq[start - 1 + k], 0);
                    }
                }
                if (start - 1 >= 0 && (sum / 4.0) > P_EXTEND) {
                    start--;
                } else {
                    break;
                }
            }

            // Extend to the right
            while (end < len - 1) {
                sum = 0.0;
                for (k = 0; k < 4; k++) {
                    if (end + 1 - k >= 0 && end + 1 - k < len) {
                        sum += get_propensity(seq[end + 1 - k], 0);
                    }
                }
                if (end + 1 < len && (sum / 4.0) > P_EXTEND) {
                    end++;
                } else {
                    break;
                }
            }

            // Validate and mark helix
            if (end - start + 1 > 5) {
                sum_a = 0.0;
                sum_b = 0.0;
                has_pro = 0;
                for (k = start; k <= end; k++) {
                    sum_a += get_propensity(seq[k], 0);
                    sum_b += get_propensity(seq[k], 1);
                    if (seq[k] == 'P') has_pro = 1;
                }
                seg_len = end - start + 1;
                avg_a = sum_a / seg_len;
                avg_b = sum_b / seg_len;

                if (!has_pro && avg_a > P_HELIX_EXTEND && avg_a > avg_b) {
                    for (k = start; k <= end; k++) {
                        if (!assigned[k]) {
                            ss[k] = HELIX;
                            assigned[k] = 1;
                        }
                    }
                }
            }
        }
    }

    /* --- Step 2: Predict Beta sheet --- */
    for (i = 0; i <= len - 5; i++) {
        count = 0;
        for (k = 0; k < 5; k++) {
            if (get_propensity(seq[i+k], 1) > 1.0) count++;
        }
        if (count >= 3) {
            start = i;
            end = i + 4;

            // Extend to the left
            while (start > 0) {
                sum = 0.0;
                for (k = 0; k < 4; k++) {
                    if (start - 1 + k >= 0 && start - 1 + k < len) {
                        sum += get_propensity(seq[start - 1 + k], 1);
                    }
                }
                if (start - 1 >= 0 && (sum / 4.0) > P_EXTEND) {
                    start--;
                } else break;
            }

            // Extend to the right
            while (end < len - 1) {
                sum = 0.0;
                for (k = 0; k < 4; k++) {
                    if (end + 1 - k >= 0 && end + 1 - k < len) {
                        sum += get_propensity(seq[end + 1 - k], 1);
                    }
                }
                if (end + 1 < len && (sum / 4.0) > P_EXTEND) {
                    end++;
                } else break;
            }

            // Validate and mark sheet
            sum_b = 0.0;
            sum_a = 0.0;
            for (k = start; k <= end; k++) {
                sum_b += get_propensity(seq[k], 1);
                sum_a += get_propensity(seq[k], 0);
            }
            seg_len = end - start + 1;
            if ((sum_b / seg_len) > P_SHEET_EXTEND && (sum_b / seg_len) > (sum_a / seg_len)) {
                for (k = start; k <= end; k++) {
                    if (!assigned[k]) {
                        ss[k] = SHEET;
                        assigned[k] = 1;
                    }
                }
            }
        }
    }

    /* --- Step 3: Predict Beta turn --- */
    for (i = 0; i <= len - 4; i++) {
        occupied = 0;
        for (k = 0; k < 4; k++) {
            if (assigned[i+k]) { occupied = 1; break; }
        }
        if (occupied) continue;

        pt_product = 1.0;
        pt_sum = 0.0;
        pa_sum = 0.0;
        pb_sum = 0.0;

        for (k = 0; k < 4; k++) {
            int idx = get_aa_index(seq[i+k]);
            double f_val;
            if (idx == -1) { pt_product = 0; break; }
            f_val = PARAMS[idx][3 + k];
            pt_product *= f_val;
            pt_sum += PARAMS[idx][2];
            pa_sum += PARAMS[idx][0];
            pb_sum += PARAMS[idx][1];
        }

        if (pt_product == 0.0) continue;

        if (pt_product > P_TURN_CUTOFF) {
            avg_pt = pt_sum / 4.0;
            avg_pa = pa_sum / 4.0;
            avg_pb = pb_sum / 4.0;

            if (avg_pt > P_TURN_AVG && avg_pa < avg_pt && avg_pb < avg_pt) {
                for (k = 0; k < 4; k++) {
                    if (!assigned[i+k]) {
                        ss[i+k] = TURN;
                    }
                }
            }
        }
    }

    free(assigned);
}

/* ==================== 4. Main Program ==================== */

int main() {
    const char* sequence = "AEALMKGYPFWVIIADGSTNPQREKLCHMFP";
    int len;
    SS_Type* ss;
    int i;
    int h, e, t, c;

    len = (int)strlen(sequence);
    if (len < 6) {
        printf("Sequence too short; Chou-Fasman algorithm requires at least 6 residues.\n");
        return 1;
    }

    printf("Input sequence (%d aa): %s\n\n", len, sequence);

    ss = (SS_Type*)malloc(sizeof(SS_Type) * len);
    if (!ss) {
        printf("Memory allocation failed.\n");
        return 1;
    }

    predict_chou_fasman(sequence, len, ss);

    printf("Pos:   ");
    for (i = 0; i < len; i++) {
        printf("%2d ", i + 1);
    }
    printf("\n");

    printf("Res:   ");
    for (i = 0; i < len; i++) {
        printf(" %c ", sequence[i]);
    }
    printf("\n");

    printf("SS:    ");
    for (i = 0; i < len; i++) {
        char c2 = ' ';
        switch (ss[i]) {
            case HELIX: c2 = 'H'; break;
            case SHEET: c2 = 'E'; break;
            case TURN:  c2 = 'T'; break;
            case COIL:  c2 = 'C'; break;
        }
        printf(" %c ", c2);
    }
    printf("\n\n");

    h = 0; e = 0; t = 0; c = 0;
    for (i = 0; i < len; i++) {
        if (ss[i] == HELIX) h++;
        else if (ss[i] == SHEET) e++;
        else if (ss[i] == TURN) t++;
        else c++;
    }
    printf("Stats: Helix = %d (%.1f%%), Sheet = %d (%.1f%%), Turn = %d (%.1f%%), Coil = %d (%.1f%%)\n",
           h, (h*100.0)/len, e, (e*100.0)/len, t, (t*100.0)/len, c, (c*100.0)/len);

    free(ss);
    return 0;
}