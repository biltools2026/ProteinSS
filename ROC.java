import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.TreeMap;

public class ROC {
	public static void main(String[] args) throws Exception {		
		ArrayList<Double> randomScores = new ArrayList<Double>();
		randomScores.clear();
		HashMap<String,Double> map = new HashMap<String,Double>();  
		map.clear();
		iValueComparator bvc =  new iValueComparator(map);
		TreeMap<String,Double> sorted_map = new TreeMap<String, Double>(bvc);	
		BufferedReader br = new BufferedReader(new FileReader(args[0]));
		String line = "";
		int n, p;
		p = 0;
		n = 0;
		int label = -1;
		int count = 0;
		while ((line = br.readLine()) != null){
			count++;
			String[] wds = line.split("\\s+");
			map.put(count + " " + line,Double.valueOf(wds[1]));
			label = Integer.valueOf(wds[0]).intValue();
			if((label==1)||((label-1)==0)){
				p++;
			}else{
				n++;
			}
		}
		br.close();
		sorted_map.clear();
		sorted_map.putAll(map);
		double A = 0;
		int FP = 0;
		int TP = 0;
		double FPprev = 0.0;
		double TPprev = 0.0;
		double fi = 0;
		double fpre = -10000;
		double v1 = 0;
		double v2 = 0;
		ArrayList<Double> x = new ArrayList<Double>();
		ArrayList<Double> y = new ArrayList<Double>();
		for(String key : sorted_map.keySet()){
			double tmp = map.get(key);
			//System.out.println(key + " " + tmp);
			String[] wds = key.split("\\s+");
			fi = tmp;
			if(1==1){	
				v1 = FP*1.0/n;
				v2 = TP*1.0/p;
				//System.out.println("FP=" + FP + " TP="+ TP+ " " + v1 + " " + v2 + " p=" + p + " n=" + n);
				x.add(v1);
				y.add(v2);				
				A = A + TRAPE_AREA(FP,FPprev,TP,TPprev);
				FPprev = FP;
				TPprev = TP;					
				fpre = fi;	
			}	
			label = Integer.valueOf(wds[1]).intValue();
			if(label==1){
				TP++;
			}else if(label==0){
				FP++;
			}else{
				System.out.println("label=" + label + " error\n");
				System.exit(1);
			}
		}
		v1 = FP/n;
		v2 = TP/p;
		x.add(v1);
		y.add(v2);		
		A = A + TRAPE_AREA(n,FPprev,p,TPprev);
		A = A*1.0/(p*n*1.0);				
		System.out.println("Auc Area=" + A);
		System.out.println("The program was written by Renxiang Yan (simipleyrx@163.com).\n");
		//System.out.println("p=" + p + " n="+n);
		FileWriter fw = new FileWriter("ROC_points.txt");
		fw.append("The program was written by Renxiang Yan (simipleyrx@163.com).");
		fw.append("Auc Area=" + A);
		fw.append("\nx    y\n");
		for(int i=0;i<x.size();i++){
			fw.append(x.get(i) + " " + y.get(i) + "\n");
		}
		fw.flush();
		fw.close();		
	}
	
	public static double TRAPE_AREA(double X1,double X2,double Y1, double Y2){
	   double base = Math.abs(X2 - X1);
	   double height = (Y1 + Y2)*1.0/2.0;
	   return base*height;
	}

}


