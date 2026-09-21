use Cwd;

#if (@ARGV<1){die($help);}

#print "OS: $^O\n";
#if ($^O eq 'MSWin32' || $^O eq 'MSWin64') {
#    print "Windows\n";
#} elsif ($^O eq 'linux') {
#    print "Linux\n";
#} 
$msystem=$^O;
$win="MSWin";
$linux="linux";

# A  R  N  D  C  Q  E  G  H  I  L  K  M  F  P  S  T  W  Y  V  X
my @BLOSUM62 = (
[ 4,-1,-2,-2, 0,-1,-1, 0,-2,-1,-1,-1,-1,-2,-1, 1, 0,-3,-2, 0, 0,-9],
[-1, 5, 0,-2,-3, 1, 0,-2, 0,-3,-2, 2,-1,-3,-2,-1,-1,-3,-2,-3,-1,-9],
[-2, 0, 6, 1,-3, 0, 0, 0, 1,-3,-3, 0,-2,-3,-2, 1, 0,-4,-2,-3,-1,-9],
[-2,-2, 1, 6,-3, 0, 2,-1,-1,-3,-4,-1,-3,-3,-1, 0,-1,-4,-3,-3,-1,-9],
[ 0,-3,-3,-3, 9,-3,-4,-3,-3,-1,-1,-3,-1,-2,-3,-1,-1,-2,-2,-1,-2,-9],
[-1, 1, 0, 0,-3, 5, 2,-2, 0,-3,-2, 1, 0,-3,-1, 0,-1,-2,-1,-2,-1,-9],
[-1, 0, 0, 2,-4, 2, 5,-2, 0,-3,-3, 1,-2,-3,-1, 0,-1,-3,-2,-2,-1,-9],
[ 0,-2, 0,-1,-3,-2,-2, 6,-2,-4,-4,-2,-3,-3,-2, 0,-2,-2,-3,-3,-1,-9],
[-2, 0, 1,-1,-3, 0, 0,-2, 8,-3,-3,-1,-2,-1,-2,-1,-2,-2, 2,-3,-1,-9],
[-1,-3,-3,-3,-1,-3,-3,-4,-3, 4, 2,-3, 1, 0,-3,-2,-1,-3,-1, 3,-1,-9],
[-1,-2,-3,-4,-1,-2,-3,-4,-3, 2, 4,-2, 2, 0,-3,-2,-1,-2,-1, 1,-1,-9],
[-1, 2, 0,-1,-3, 1, 1,-2,-1,-3,-2, 5,-1,-3,-1, 0,-1,-3,-2,-2,-1,-9],
[-1,-1,-2,-3,-1, 0,-2,-3,-2, 1, 2,-1, 5, 0,-2,-1,-1,-1,-1, 1,-1,-9],
[-2,-3,-3,-3,-2,-3,-3,-3,-1, 0, 0,-3, 0, 6,-4,-2,-2, 1, 3,-1,-1,-9],
[-1,-2,-2,-1,-3,-1,-1,-2,-2,-3,-3,-1,-2,-4, 7,-1,-1,-4,-3,-2,-2,-9],
[ 1,-1, 1, 0,-1, 0, 0, 0,-1,-2,-2, 0,-1,-2,-1, 4, 1,-3,-2,-2, 0,-9],
[ 0,-1, 0,-1,-1,-1,-1,-2,-2,-1,-1,-1,-1,-2,-1, 1, 5,-2,-2, 0, 0,-9],
[-3,-3,-4,-4,-2,-2,-3,-2,-2,-3,-2,-3,-1, 1,-4,-3,-2,11, 2,-3,-2,-9],
[-2,-2,-2,-3,-2,-1,-2,-3, 2,-1,-1,-2,-1, 3,-3,-2,-2, 2, 7,-1,-1,-9],
[ 0,-3,-3,-3,-1,-2,-2,-3,-3, 3, 1,-2, 1,-1,-2,-2, 0,-3,-1, 4,-1,-9],
[ 0,-1,-1,-1,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-2, 0, 0,-2,-1,-1,-1,-9],
[-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9]	  
    );
    
my @AMINO_ACIDS = qw(
    C M F I L V W Y A G T S Q N E D H R K P
);

my @Gonnet = (
#  A    R    N    D    C    Q    E    G    H    I    L    K    M    F    P    S    T    W    Y    V    X     
#   The Gonnet matrix is in units of 10*log10()
[ 2.4,-0.6,-0.3,-0.3, 0.5,-0.2, 0.0, 0.5,-0.8,-0.8,-1.2,-0.4,-0.7,-2.3, 0.3, 1.1, 0.6,-3.6,-2.2, 0.1,-1.0,-9.9], # A
[-0.6, 4.7, 0.3,-0.3,-2.2, 1.5, 0.4,-1.0, 0.6,-2.4,-2.2, 2.7,-1.7,-3.2,-0.9,-0.2,-0.2,-1.6,-1.8,-2.0,-1.0,-9.9], # R
[-0.3, 0.3, 3.8, 2.2,-1.8, 0.7, 0.9, 0.4, 1.2,-2.8,-3.0, 0.8,-2.2,-3.1,-0.9, 0.9, 0.5,-3.6,-1.4,-2.2,-1.0,-9.9], # N
[-0.3,-0.3, 2.2, 4.7,-3.2, 0.9, 2.7, 0.1, 0.4,-3.8,-4.0, 0.5,-3.0,-4.5,-0.7, 0.5, 0.0,-5.2,-2.8,-2.9,-1.0,-9.9], # D
[ 0.5,-2.2,-1.8,-3.2,11.5,-2.4,-3.0,-2.0,-1.3,-1.1,-1.5,-2.8,-0.9,-0.8,-3.1, 0.1,-0.5,-1.0,-0.5, 0.0,-1.0,-9.9], # C
[-0.2, 1.5, 0.7, 0.9,-2.4, 2.7, 1.7,-1.0, 1.2,-1.9,-1.6, 1.5,-1.0,-2.6,-0.2, 0.2, 0.0,-2.7,-1.7,-1.5,-1.0,-9.9], # Q
[ 0.0, 0.4, 0.9, 2.7,-3.0, 1.7, 3.6,-0.8, 0.4,-2.7,-2.8, 1.2,-2.0,-3.9,-0.5, 0.2,-0.1,-4.3,-2.7,-1.9,-1.0,-9.9], # E
[ 0.5,-1.0, 0.4, 0.1,-2.0,-1.0,-0.8, 6.6,-1.4,-4.5,-4.4,-1.1,-3.5,-5.2,-1.6, 0.4,-1.1,-4.0,-4.0,-3.3,-1.0,-9.9], # G
[-0.8, 0.6, 1.2, 0.4,-1.3, 1.2, 0.4,-1.4, 6.0,-2.2,-1.9, 0.6,-1.3,-0.1,-1.1,-0.2,-0.3,-0.8,-2.2,-2.0,-1.0,-9.9], # H
[-0.8,-2.4,-2.8,-3.8,-1.1,-1.9,-2.7,-4.5,-2.2, 4.0, 2.8,-2.1, 2.5, 1.0,-2.6,-1.8,-0.6,-1.8,-0.7, 3.1,-1.0,-9.9], # I
[-1.2,-2.2,-3.0,-4.0,-1.5,-1.6,-2.8,-4.4,-1.9, 2.8, 4.0,-2.1, 2.8, 2.0,-2.3,-2.1,-1.3,-0.7, 0.0, 1.8,-1.0,-9.9], # L
[-0.4, 2.7, 0.8, 0.5,-2.8, 1.5, 1.2,-1.1, 0.6,-2.1,-2.1, 3.2,-1.4,-3.3,-0.6, 0.1, 0.1,-3.5,-2.1,-1.7,-1.0,-9.9], # K
[-0.7,-1.7,-2.2,-3.0,-0.9,-1.0,-2.0,-3.5,-1.3, 2.5, 2.8,-1.4, 4.3, 1.6,-2.4,-1.4,-0.6,-1.0,-0.2, 1.6,-1.0,-9.9], # M
[-2.3,-3.2,-3.1,-4.5,-0.8,-2.6,-3.9,-5.2,-0.1, 1.0, 2.0,-3.3, 1.6, 7.0,-3.8,-2.8,-2.2, 3.6, 5.1, 0.1,-1.0,-9.9], # F
[ 0.3,-0.9,-0.9,-0.7,-3.1,-0.2,-0.5,-1.6,-1.1,-2.6,-2.3,-0.6,-2.4,-3.8, 7.6, 0.4, 0.1,-5.0,-3.1,-1.8,-1.0,-9.9], # P
[ 1.1,-0.2, 0.9, 0.5, 0.1, 0.2, 0.2, 0.4,-0.2,-1.8,-2.1, 0.1,-1.4,-2.8, 0.4, 2.2, 1.5,-3.3,-1.9,-1.0,-1.0,-9.9], # S
[ 0.6,-0.2, 0.5, 0.0,-0.5, 0.0,-0.1,-1.1,-0.3,-0.6,-1.3, 0.1,-0.6,-2.2, 0.1, 1.5, 2.5,-3.5,-1.9, 0.0,-1.0,-9.9], # T
[-3.6,-1.6,-3.6,-5.2,-1.0,-2.7,-4.3,-4.0,-0.8,-1.8,-0.7,-3.5,-1.0, 3.6,-5.0,-3.3,-3.5,14.2, 4.1,-2.6,-1.0,-9.9], # W
[-2.2,-1.8,-1.4,-2.8,-0.5,-1.7,-2.7,-4.0,-2.2,-0.7, 0.0,-2.1,-0.2, 5.1,-3.1,-1.9,-1.9, 4.1, 7.8,-1.1,-1.0,-9.9], # Y
[ 0.1,-2.0,-2.2,-2.9, 0.0,-1.5,-1.9,-3.3,-2.0, 3.1, 1.8,-1.7, 1.6, 0.1,-1.8,-1.0, 0.0,-2.6,-1.1, 3.4,-1.0,-9.9], # V
[-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-9.9], # X	  
[-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9]  # ~	  
);

%onetothree = ('GLY'=>'G','ALA'=>'A','VAL'=>'V','LEU'=>'L','ILE'=>'I','SER'=>'S','THR'=>'T','CYS'=>'C','MET'=>'M','PRO'=>'P','ASP'=>'D','ASN'=>'N','GLU'=>'E','GLN'=>'Q','LYS'=>'K','ARG'=>'R','HIS'=>'H','PHE'=>'F','TYR'=>'Y','TRP'=>'W','ASX'=>'B','GLX'=>'Z','UNK'=>'X','G'=>'GLY','A'=>'ALA','V'=>'VAL','L'=>'LEU','I'=>'ILE','S'=>'SER','T'=>'THR','C'=>'CYS','M'=>'MET','P'=>'PRO','D'=>'ASP','N'=>'ASN','E'=>'GLU','Q'=>'GLN','K'=>'LYS','R'=>'ARG','H'=>'HIS','F'=>'PHE','Y'=>'TYR','W'=>'TRP','a'=>'ALA','b'=>'ASN','c'=>'CYS','d'=>'ASP','e'=>'GLU','f'=>'PHE','g'=>'GLY','h'=>'HIS','i'=>'ILE','j'=>'GLY','k'=>'LYS','l'=>'LEU','m'=>'MET','n'=>'ASN','o'=>'GLY','p'=>'PRO','q'=>'GLN','r'=>'ARG','s'=>'SER','t'=>'THR','u'=>'GLY','v'=>'VAL','w'=>'TRP','x'=>'GLY','y'=>'TYR','z'=>'GLN','B'=>'ASN','Z'=>'GLN','X'=>'GLY');
%threetoone = ('GLY'=>'G','ALA'=>'A','VAL'=>'V','LEU'=>'L','ILE'=>'I','SER'=>'S','THR'=>'T','CYS'=>'C','MET'=>'M','PRO'=>'P','ASP'=>'D','ASN'=>'N','GLU'=>'E','GLN'=>'Q','LYS'=>'K','ARG'=>'R','HIS'=>'H','PHE'=>'F','TYR'=>'Y','TRP'=>'W','ASX'=>'B','GLX'=>'Z','UNK'=>'X','G'=>'GLY','A'=>'ALA','V'=>'VAL','L'=>'LEU','I'=>'ILE','S'=>'SER','T'=>'THR','C'=>'CYS','M'=>'MET','P'=>'PRO','D'=>'ASP','N'=>'ASN','E'=>'GLU','Q'=>'GLN','K'=>'LYS','R'=>'ARG','H'=>'HIS','F'=>'PHE','Y'=>'TYR','W'=>'TRP','a'=>'ALA','b'=>'ASN','c'=>'CYS','d'=>'ASP','e'=>'GLU','f'=>'PHE','g'=>'GLY','h'=>'HIS','i'=>'ILE','j'=>'GLY','k'=>'LYS','l'=>'LEU','m'=>'MET','n'=>'ASN','o'=>'GLY','p'=>'PRO','q'=>'GLN','r'=>'ARG','s'=>'SER','t'=>'THR','u'=>'GLY','v'=>'VAL','w'=>'TRP','x'=>'GLY','y'=>'TYR','z'=>'GLN','B'=>'ASN','Z'=>'GLN','X'=>'GLY');
@AA = qw(C M F I L V W Y A G T S Q N E D H R K P);

# 二级结构到编码的映射
%SS = (
    'H' => 2,    # 螺旋
    'E' => 4,    # 片层
    'T' => 3,    # 转角
    'C' => 1,    # 无规卷曲
    'c' => 1,
    'h' => 2,
    't' => 3,
    'e' => 4,
);

# 编码到二级结构的反向映射
our %SS_REVERSE = (
    1 => 'C',
    2 => 'H',
    3 => 'T',
    4 => 'E',
);

# 氨基酸单字母转三字母
our %AA_NAMES = (
    'A' => 'ALA', 'C' => 'CYS', 'D' => 'ASP', 'E' => 'GLU',
    'F' => 'PHE', 'G' => 'GLY', 'H' => 'HIS', 'I' => 'ILE',
    'K' => 'LYS', 'L' => 'LEU', 'M' => 'MET', 'N' => 'ASN',
    'P' => 'PRO', 'Q' => 'GLN', 'R' => 'ARG', 'S' => 'SER',
    'T' => 'THR', 'V' => 'VAL', 'W' => 'TRP', 'Y' => 'TYR',
);

# 氨基酸全名
our %AA_FULL_NAMES = (
    'A' => 'Alanine',     'C' => 'Cysteine',
    'D' => 'Aspartic acid', 'E' => 'Glutamic acid',
    'F' => 'Phenylalanine', 'G' => 'Glycine',
    'H' => 'Histidine',   'I' => 'Isoleucine',
    'K' => 'Lysine',      'L' => 'Leucine',
    'M' => 'Methionine',  'N' => 'Asparagine',
    'P' => 'Proline',     'Q' => 'Glutamine',
    'R' => 'Arginine',    'S' => 'Serine',
    'T' => 'Threonine',   'V' => 'Valine',
    'W' => 'Tryptophan',  'Y' => 'Tyrosine',
);    

$rlinux = 3;
    
#######  common parameters ####################################
my $NAME_WIDTH = 6;
my $POSITION_WIDTH = 3;
my $SEQUENCE_WIDTH = 80;
my $BLANK = " ";

my %three_to_one = (
    'GLY' => 'G', 'ALA' => 'A', 'VAL' => 'V', 'LEU' => 'L', 'ILE' => 'I',
    'SER' => 'S', 'THR' => 'T', 'CYS' => 'C', 'MET' => 'M', 'PRO' => 'P',
    'ASP' => 'D', 'ASN' => 'N', 'GLU' => 'E', 'GLN' => 'Q', 'LYS' => 'K',
    'ARG' => 'R', 'HIS' => 'H', 'PHE' => 'F', 'TYR' => 'Y', 'TRP' => 'W',
    'ASX' => 'B', 'GLX' => 'Z', 'UNK' => 'X',
);

%SA1 = ("A"=>110.2,"C"=>140.4,"D"=>144.1,"E"=>174.7,"F"=>200.7,"G"=>78.7,"H"=>181.9,"I"=>185.0,"K"=>205.7,"L"=>183.1,"M"=>200.1,"N"=>146.4,"P"=>141.9,"Q"=>178.6,"R"=>229.0,"S"=>117.2,"T"=>138.7,"V"=>153.7,"W"=>240.5,"Y"=>213.7);
%SA3 = (
    "ALA" => 110.2, "CYS" => 140.4, "ASP" => 144.1, "GLU" => 174.7,
    "PHE" => 200.7, "GLY" => 78.7,  "HIS" => 181.9, "ILE" => 185.0,
    "LYS" => 205.7, "LEU" => 183.1, "MET" => 200.1, "ASN" => 146.4,
    "PRO" => 141.9, "GLN" => 178.6, "ARG" => 229.0, "SER" => 117.2,
    "THR" => 138.7, "VAL" => 153.7, "TRP" => 240.5, "TYR" => 213.7
);

my @standard_amino_acids = qw(
    GLY ALA VAL LEU ILE SER THR CYS MET PRO ASP ASN GLU GLN LYS ARG HIS PHE TYR TRP ASX GLX
);

my $options = "";
my $gpen = -11;
my $gextn = -1;   
#######  common parameters ####################################

for($i=0;$i<@ARGV;$i++){$options .= " $ARGV[$i] ";}
if($options=~/ \-hydro\s+(\S+)\s+(\w+)/){
    	print "$1 $2\n";
    	$seq=$1;
    	$win=$2;
    	$win=($win-1)/2.0;
    	print "perl ./code/Chothia.pl $seq $win > .\\$seq.hydropathy.Chothia.txt\n";
    	system("perl ./code/Chothia.pl $seq $win > .\\hydropathy.Chothia.txt");
    	system("perl ./code/KyteDoolittle.pl $seq $win > .\\hydropathy.KyteDoolittle.txt");    	
    	#system("perl .\\code\\Chothia.pl .\\example\\3ZE5\\3ZE5.fasta 4 > .\\a.txt");    	
}elsif($options=~/ \-aa\s+(\S+)/){
	$seq=$1;
	#system("perl .\\code\\aa.pl $seq");
	calculate_aa_distribution($seq);
}elsif(($options=~/ \-embedding\s+(\S+)/)||($options=~/ \-embeding\s+(\S+)/)){
	$seq=$1;
	# embedding($seq); # This procedure generates embedding features for proteins
	print "Generate CKSAAP encoding\n";  # need 3 scripts to generate CKSAAP, cksaap_main.pl, CKSAAP_mod.pl, and kspace_run.pl
	if(!-e "cksaap_main.pl"){
        system("copy code\\cksaap_main.pl .");
    }
    if(!-e "CKSAAP_mod.pl"){
        system("copy code\\CKSAAP_mod.pl .");
    }
    if(!-e "kspace_run.pl"){
        system("copy code\\kspace_run.pl .");
    }
	$res = `perl cksaap_main.pl $seq 12`;
    print "$res";

	$libdir=".\\fold\\";
	$blastdir="$libdir\\windb\\ncbi-blast-2.2.24";
    if($rlinux==1){
        $blastdir="$libdir\\windb\\linux\\ncbi-blast-2.2.24";
    }
	# print `$blastdir\\bin\\psiblast -comp_based_stats 0 -query $seq -db $libdir\\windb\\db.seq -out_ascii_pssm $seq.ascii_pssm -out_pssm  seq.out_pssm -evalue 0.0001 -num_iterations 3 > tblast.out`;	
	print `$blastdir\\bin\\psiblast -query $seq -db $libdir\\windb\\db.seq -out_ascii_pssm $seq.ascii_pssm -out_pssm  seq.out_pssm -evalue 0.0001 -num_iterations 3 > tblast.out`;
	print "Generate PSSM-CKSAAP encoding\n";
	PSSMCKSAAPEncoding("$seq","$seq\.ascii_pssm",12);
}elsif($options=~/ \-pssmcksaap\s+(\S+)\s+(\S+)\s+(\S+)/){    
	PSSMCKSAAPEncoding("$1","$2","$3");
}elsif($options=~/ \-vina\s+(\S+)\s+(\S+)\s+\-config\s+(\S+)/){  ##### input configure file directory
	$protein=$1;
	$ligand=$2;
	$box=$3;
	# print "$1 $2 $3\n";
	$vpath="bin/vina/v.exe";
	if($msystem=~/$win\d+/){
			$vpath="bin/vina/v.exe";
	}elsif(($msystem=~/$linux/)||($msystem=~/"Linux"/)){
			$vpath="bin/vina/v.linux";
	}	
	if(get_python_version()==2){
		print("python 2\n");
		system("python.exe code/merge.python2.7.v2.1.py -r $protein");
	    system("python.exe code/merge.python2.7.v2.1.py -l $ligand");
    }elsif(get_python_version()==3){
		print("python 3\n");
        # system("python.exe src/d/new.merge.python3.v3.py -r $protein");
	    # system("python.exe src/d/new.merge.python3.v3.py -l $ligand");
		system("python.exe code/new.merge.python3.v4.py -r $protein");
	    system("python.exe code/new.merge.python3.v4.py -l $ligand");
	}else{
		print("Python was not set. Please add Python in your system path");
		exit();	
	}	
	$proteinpdbqt = $protein . "qt";
	$ligandpdbqt = $ligand . "qt";	
	system("$vpath --config $box");
	$mfile=$ligandpdbqt;
	$mfile=~s/\.pdbqt//;
	#print "mfile=$mfile\n";
	#print "($mfile . _out.pdbqt)\n";
	
	$sss = " ";
	$kkk = "TORSDOF";
	$flag = 0;
	$nf = "m." . "$mfile" . "_out.pdbqt";
	open(OUT,">$nf");
	open(IN,"$mfile" . "_out.pdbqt");
		while($line=<IN>){
			# print "$line";
			if($line=~/^ENDMDL/){
				$flag = 0;
			}
			
			if($flag!=1){
				print OUT "$line";
			}
			
			if($line=~/^$kkk/){
				$flag = 1;
			}else{
				$flag = 0;
			}
		}
	close IN;
	close OUT;	
	msplit("m." . "$mfile" . "_out.pdbqt",$protein);
	# msplit("$mfile" . "_out.pdbqt",$protein);
}elsif($options=~/ \-vina\s+(\S+)\s+(\S+)\s+(\S+)/){  ### add chain information
	$protein=$1;
	$ligand=$2;
	$box=$3;
	# print "$1 $2 $3\n";
	$vpath="bin/vina/v.exe";
	if($msystem=~/$win\d+/){
			$vpath="bin/vina/v.exe";
	}elsif(($msystem=~/$linux/)||($msystem=~/"Linux"/)){
			$vpath="bin/vina/v.linux";
	}	
	if(get_python_version()==2){
		print("python 2\n");
		system("python.exe code/merge.python2.7.v2.1.py -r $protein");
	    system("python.exe code/merge.python2.7.v2.1.py -l $ligand");
    }elsif(get_python_version()==3){
		print("python 3\n");
        # system("python.exe src/d/new.merge.python3.v3.py -r $protein");
	    # system("python.exe src/d/new.merge.python3.v3.py -l $ligand");
		system("python.exe code/new.merge.python3.v4.py -r $protein");
	    system("python.exe code/new.merge.python3.v4.py -l $ligand");
	}else{
		print("Python was not set. Please add Python in your system path");
		exit();	
	}	
	my @resList=();
	my @numList=();
    my @chainList=();
    $isChain = 0;
	open(IN,"$box")||die "can not open residue number file.txt";
cchain:	while($line=<IN>){
            $line=~s/^\s+//g;
            if($line=~/^([A-Z]+)(\d+)\s+([A-Z])/){  ### residue-num chain format
                $res=$1;
				$num=$2;
                $mmchain=$3;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
                push(@chainList,$mmchain);
                $isChain = 1;       
                next cchain;
            }          
            $line=~s/\s+//g;
			if($line=~/^([A-Z]+)(\d+)$/){  ### residue-num format
				$res=$1;
				$num=$2;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/^([A-Z]+)(\d+)$/){
				$res=$1;
				$num=$2;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/^\s+([A-Z]+)(\d+)$/){
				$res=$1;
				$num=$2;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/\s+([A-Z]+)(\d+)\s+/){
				$res=$1;
				$num=$2;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/\s+([A-Z]+)\s+(\d+)\s+/){
				$res=$1;
				$num=$2;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/([A-Z]+)\s+(\d+)/){
				$res=$1;
				$num=$2;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/([A-Z]+)\s+(\d+)\s+/){
				$res=$1;
				$num=$2;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/^(\d+)([A-Z]+)$/){   ### num-residue format
				$res=$2;
				$num=$1;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/^(\d+)([A-Z]+)$/){
				$res=$2;
				$num=$1;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/^\s+(\d+)([A-Z]+)$/){
				$res=$2;
				$num=$1;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/\s+(\d+)([A-Z]+)\s+/){
				$res=$2;
				$num=$1;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/\s+(\d+)([A-Z]+)\s+\s+/){
				$res=$2;
				$num=$1;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/(\d+)([A-Z]+)\s+/){
				$res=$2;
				$num=$1;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/(\d+)([A-Z]+)\s+\s+/){
				$res=$2;
				$num=$1;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}else{
				print "The format of active site file ($box) is not correct\n";
				exit(0);				
			}
		}
	close IN;
	my @xList=();
	my @yList=();
	my @zList=();	
	for($i=0;$i<@resList;$i++){		
        if($isChain==0){
            $result=extractPDB($protein,$resList[$i],$numList[$i]);
        }else{
            $result=extractPDB($protein,$resList[$i],$numList[$i],$chainList[$i]);
            print "$result=extractPDB($protein,$resList[$i],$numList[$i],$chainList[$i])\n";
        }
		# print "$result=extractPDB($protein,$resList[$i],$numList[$i])\n";
		@wds=split(/\s+/,$result);
		my $tx=$wds[0];
		my $ty=$wds[1];
		my $tz=$wds[2];
		push(@xList,$tx);
		push(@yList,$ty);
		push(@zList,$tz);
	}
	my $xcenter,$ycenter,$zcenter;
	$n=@xList;
	$sum=0;
	for($i=0;$i<@xList;$i++){
		$sum=$sum+$xList[$i];
	}
	$xcenter=$sum/$n;
	
	$n=@yList;
	$sum=0;
	for($i=0;$i<@yList;$i++){
		$sum=$sum+$yList[$i];
	}
	$ycenter=$sum/$n;
	
	$n=@zList;
	$sum=0;
	for($i=0;$i<@zList;$i++){
		$sum=$sum+$zList[$i];
	}
	$zcenter=$sum/$n;
	$proteinpdbqt = $protein . "qt";
	$ligandpdbqt = $ligand . "qt";	
	my $config_text = conf1($proteinpdbqt, $ligandpdbqt,$xcenter,$ycenter,$zcenter);
	#print "xcenter=$xcenter ycenter=$ycenter zcenter=$zcenter\n";
	printf "xcenter=%.3f ycenter=%.3f zcenter=%.3f\n", $xcenter, $ycenter, $zcenter;
	#sprintf("xcenter=%.3f ycenter=%.3f zcenter=%.3f\n", $xcenter, $ycenter, $zcenter);
    # print sprintf("xcenter=%.3f ycenter=%.3f zcenter=%.3f\n", $xcenter, $ycenter, $zcenter);
	#my $config_text = conf($proteinpdbqt, $ligandpdbqt);
	open(my $fh, '>', 'conf.txt') or die "Cannot open file: $!";
		print $fh $config_text;
	close $fh;	
	# print "bin\\vina\\msuit\\v.exe --config conf.txt\n";
	system("$vpath --config conf.txt");
	$mfile=$ligandpdbqt;
	$mfile=~s/\.pdbqt//;
	#print "mfile=$mfile\n";
	#print "($mfile . _out.pdbqt)\n";
	
	$sss = " ";
	$kkk = "TORSDOF";
	$flag = 0;
	$nf = "m." . "$mfile" . "_out.pdbqt";
	open(OUT,">$nf");
	open(IN,"$mfile" . "_out.pdbqt");
		while($line=<IN>){
			# print "$line";
			if($line=~/^ENDMDL/){
				$flag = 0;
			}
			
			if($flag!=1){
				print OUT "$line";
			}
			
			if($line=~/^$kkk/){
				$flag = 1;
			}else{
				$flag = 0;
			}
		}
	close IN;
	close OUT;	
	msplit("m." . "$mfile" . "_out.pdbqt",$protein);
	# msplit("$mfile" . "_out.pdbqt",$protein);
}elsif($options=~/ \-vina\s+(\S+)\s+(\S+)/){  ###### use ca center of protein to set the box
	$protein=$1;
	$ligand=$2;
	# print "$1 $2 $3\n";
	$vpath="bin/vina/v.exe";
	if($msystem=~/$win\d+/){
			$vpath="bin/vina/v.exe";
	}elsif(($msystem=~/$linux/)||($msystem=~/"Linux"/)){
			$vpath="bin/vina/v.linux";
	}	
	if(get_python_version()==2){
		print("python 2\n");
		system("python.exe code/merge.python2.7.v2.1.py -r $protein");
	    system("python.exe code/merge.python2.7.v2.1.py -l $ligand");
    }elsif(get_python_version()==3){
		print("python 3\n");
        # system("python.exe src/d/new.merge.python3.v3.py -r $protein");
	    # system("python.exe src/d/new.merge.python3.v3.py -l $ligand");
		system("python.exe code/new.merge.python3.v4.py -r $protein");
	    system("python.exe code/new.merge.python3.v4.py -l $ligand");
	}else{
		print("Python was not set. Please add Python in your system path");
		exit();	
	}		
	my @xList=();
	my @yList=();
	my @zList=();	
	$res = cacenter($protein);
	@wds = split(/\s+/,$res);
	push(@xList,$wds[0]);
	push(@yList,$wds[1]);
	push(@zList,$wds[2]);
	my $xcenter,$ycenter,$zcenter;
	$n=@xList;
	$sum=0;
	for($i=0;$i<@xList;$i++){
		$sum=$sum+$xList[$i];
	}
	$xcenter=$sum/$n;
	
	$n=@yList;
	$sum=0;
	for($i=0;$i<@yList;$i++){
		$sum=$sum+$yList[$i];
	}
	$ycenter=$sum/$n;
	
	$n=@zList;
	$sum=0;
	for($i=0;$i<@zList;$i++){
		$sum=$sum+$zList[$i];
	}
	$zcenter=$sum/$n;
	$proteinpdbqt = $protein . "qt";
	$ligandpdbqt = $ligand . "qt";	
	my $config_text = conf1cacenter($proteinpdbqt, $ligandpdbqt,$xcenter,$ycenter,$zcenter);
	# print "kkk xcenter=$xcenter ycenter=$ycenter zcenter=$zcenter\n";
	printf "xcenter=%.3f ycenter=%.3f zcenter=%.3f\n", $xcenter, $ycenter, $zcenter;
	# sprintf("xcenter=%.3f ycenter=%.3f zcenter=%.3f\n", $xcenter, $ycenter, $zcenter);
    # print sprintf("xcenter=%.3f ycenter=%.3f zcenter=%.3f\n", $xcenter, $ycenter, $zcenter);
	#my $config_text = conf($proteinpdbqt, $ligandpdbqt);
	open(my $fh, '>', 'conf.txt') or die "Cannot open file: $!";
		print $fh $config_text;
	close $fh;	
	# print "bin\\vina\\msuit\\v.exe --config conf.txt\n";
	system("$vpath --config conf.txt");
	$mfile=$ligandpdbqt;
	$mfile=~s/\.pdbqt//;
	#print "mfile=$mfile\n";
	#print "($mfile . _out.pdbqt)\n";
	
	$sss = " ";
	$kkk = "TORSDOF";
	$flag = 0;
	$nf = "m." . "$mfile" . "_out.pdbqt";
	open(OUT,">$nf");
	open(IN,"$mfile" . "_out.pdbqt");
		while($line=<IN>){
			# print "$line";
			if($line=~/^ENDMDL/){
				$flag = 0;
			}
			
			if($flag!=1){
				print OUT "$line";
			}
			
			if($line=~/^$kkk/){
				$flag = 1;
			}else{
				$flag = 0;
			}
		}
	close IN;
	close OUT;	
	msplit("m." . "$mfile" . "_out.pdbqt",$protein);
}elsif($options=~/ \-ss\s+(\S+)/){
	$pdb=$1;
    if($options=~/ \-ss\s+(\S+)\s+(\S+)/){
        $t=$2; 
    }
    if(($t eq "t4")||($t eq "4t")){
        sst4($pdb); # output secondary structures with four types, H: Helix, E: strand, C: coil and T: T-turn.
    }else{
        ss($pdb);   # output secondary structures with three types, H: Helix, E: strand and C: coil.
    }
}elsif($options=~/ \-msa2psfm\s+(\S+)\s+(\S+)/){
    $msa = $1;
    $psfm = $2;
    MSA2PSFM("$msa","$psfm");
}elsif($options=~/ \-pdb2seq\s+(\S+)/){
	$pdb=$1;
	#system("perl .\\src\\aa\\aa.pl $seq");
	pdb2seq($pdb);
}elsif($options=~/ \-cu\s+(\S+)/){
	$pdb=$1;
	#system("perl .\\src\\aa\\aa.pl $seq");
	ionfinder($pdb,"CU");
}elsif($options=~/ \-zn\s+(\S+)/){
	$pdb=$1;
	#system("perl .\\src\\aa\\aa.pl $seq");
	ionfinder($pdb,"ZN");
}elsif(($options=~/ \-nwalign\s+(\S+)\s+(\S+)/)||($options=~/ \-nw\s+(\S+)\s+(\S+)/)){  
	$z1=$1;
	$z2=$2;
	print "seq1=$z1  seq2=$z2\n";
	
	######################################################
	
	$window_size = -1;
	if($options=~/ \-nwalign\s+(\S+)\s+(\S+)\s+(\d+)/){
		$window_size = $3;
		print "window_size=$window_size\n";
	}		
	######################################################
	
	my $seq1 = "";
    my $seq2 = "";    
    $seq1 = read_fasta_or_raw_sequence($z1);
    $seq2 = read_fasta_or_raw_sequence($z2);
    #print "seq1=$seq1\n";
    #print "seq2=$seq2\n";
	my $tNAME_WIDTH=$NAME_WIDTH,$tPOSITION_WIDTH=$POSITION_WIDTH;
    my $tSEQUENCE_WIDTH=$SEQUENCE_WIDTH;
    my $tBLANK=$BLANK;
	if($window_size!=-1){
		$tSEQUENCE_WIDTH = $window_size;
	}
	needleman_wunsch(uc($seq1), uc($seq2),$tNAME_WIDTH,$tPOSITION_WIDTH,$tSEQUENCE_WIDTH,$tBLANK,$gpen,$gextn);
	#my ($seq1, $seq2,$tNAME_WIDTH,$tPOSITION_WIDTH,$tSEQUENCE_WIDTH,$tBLANK) = @_;
}elsif($options=~/ \-lpdb2pdbqt\s+(\S+)/){
	$lpdb=$1;
	if(get_python_version()==2){
		print("python 2 existed\n");
	    system("python.exe code/merge.python2.7.v2.1.py -l $lpdb");
    }elsif(get_python_version()==3){
		print("python 3 existed\n");
	    system("python.exe code/new.merge.python3.v4.py -l $lpdb");
	}else{
		print("Python was not set. Please add Python in your system path");
		exit();	
	}	
}elsif($options=~/ \-ppdb2pdbqt\s+(\S+)/){
	$ppdb=$1;
	if(get_python_version()==2){
		print("python 2\n");
	    system("python.exe code/merge.python2.7.v2.1.py -r $ppdb");
    }elsif(get_python_version()==3){
		print("python 3\n");
	    system("python.exe code/new.merge.python3.v4.py -r $ppdb");
	}else{
		print("Python was not set. Please add Python in your system path");
		exit();	
	}	
}elsif(($options=~/ \-swalign\s+(\S+)\s+(\S+)/)||($options=~/ \-sw\s+(\S+)\s+(\S+)/)){
	$z1=$1;
	$z2=$2;
	print "seq1=$z1  seq2=$z2\n";
	my $seq1 = "";
    my $seq2 = "";    
    $seq1 = read_fasta_or_raw_sequence($z1);
    $seq2 = read_fasta_or_raw_sequence($z2);
    my $tNAME_WIDTH=$NAME_WIDTH,$tPOSITION_WIDTH=$POSITION_WIDTH;
    my $tSEQUENCE_WIDTH=$SEQUENCE_WIDTH;
    my $tBLANK=$BLANK;
	
	$window_size = -1;
	if($options=~/ \-swalign\s+(\S+)\s+(\S+)\s+(\d+)/){
		$window_size = $3;
		print "window_size=$window_size\n";
	}	
	if($window_size!=-1){
		$tSEQUENCE_WIDTH = $window_size;
	}
	
	smith_waterman(uc($seq1), uc($seq2),$tNAME_WIDTH,$tPOSITION_WIDTH,$tSEQUENCE_WIDTH,$tBLANK,$gpen,$gextn);
}elsif($options=~/ \-drugscreen\s+(\S+)\s+(\S+)\s+(\S+)/){
	$protein=$1;
	$druglibrary=$2;
	$box=$3;
	print "$1 $2 $3\n";
	if(get_python_version()==2){
		print("python 2\n");
	    system("python.exe code/merge.python2.7.v2.1.py -r $protein");
    }elsif(get_python_version()==3){
		print("python 3\n");
	    system("python.exe code/new.merge.python3.v4.py -r $protein");
	}else{
		print("Python was not set. Please add Python in your system path");
		exit();	
	}	
	my @resList=();
	my @numList=();
	open(IN,"$box")||die "can not open residue number file.txt";
		while($line=<IN>){
			if($line=~/^([A-Z]+)(\d+)$/){
				$res=$1;
				$num=$2;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}elsif($line=~/^([A-Z]+)(\d+)$/){
				$res=$1;
				$num=$2;
				print "Active site $res $num\n";
				push(@resList,$res);
				push(@numList,$num);
			}
		}
	close IN;
	my @xList=();
	my @yList=();
	my @zList=();	
	for($i=0;$i<@resList;$i++){		
		$result=extractPDB($protein,$resList[$i],$numList[$i]);
		print "$result=extractPDB($protein,$resList[$i],$numList[$i])\n";
		@wds=split(/\s+/,$result);
		my $tx=$wds[0];
		my $ty=$wds[1];
		my $tz=$wds[2];
		push(@xList,$tx);
		push(@yList,$ty);
		push(@zList,$tz);
	}
	my $xcenter,$ycenter,$zcenter;
	$n=@xList;
	$sum=0;
	for($i=0;$i<@xList;$i++){
		$sum=$sum+$xList[$i];
	}
	$xcenter=$sum/$n;
	
	$n=@yList;
	$sum=0;
	for($i=0;$i<@yList;$i++){
		$sum=$sum+$yList[$i];
	}
	$ycenter=$sum/$n;
	
	$n=@zList;
	$sum=0;
	for($i=0;$i<@zList;$i++){
		$sum=$sum+$zList[$i];
	}
	$zcenter=$sum/$n;
	$proteinpdbqt = $protein . "qt";
	print "xcenter=$xcenter ycenter=$ycenter zcenter=$zcenter\n";
	my $config_text = conf1($proteinpdbqt, "lib",$xcenter,$ycenter,$zcenter);
	#my $config_text = conf($proteinpdbqt, $ligandpdbqt);
	open(my $fh, '>', 'conf_screen.txt') or die "Cannot open file: $!";
		print $fh $config_text;
	close $fh;	
	
	@drugList=();
	open(IN,"$druglibrary")||print "can not open $druglibrary";
		while($line=<IN>){
			chomp($line);
			push(@drugList,$line);
		}
	close IN;
	
	for($i=0;$i<@drugList;$i++){
		print "screen $i  $drugList[$i]\n";
		$vpath="bin/vina/v.exe";
		if($msystem=~/$win\d+/){
				$vpath="bin/vina/v.exe";
		}elsif(($msystem=~/$linux/)||($msystem=~/"Linux"/)){
				$vpath="bin/vina/v.linux";
		}	
		#print("$vpath --config conf_screen.txt --ligand lib/drugLibrary/database/$drugList[$i]  --log  $drugList[$i].log.txt  --out $drugList[$i].out.txt");
		print system("$vpath --config conf_screen.txt --ligand lib/drugLibrary/database/$drugList[$i]  --out $drugList[$i].out.txt");
		#exit();
	}
	
	#parse the docking results and rank by the binding scores
	%hash=();
	for($i=0;$i<@drugList;$i++){
		open(IN,"$drugList[$i].out.txt");
			$line=<IN>;
			$line=<IN>;
			@wds = split(/\s+/,$line);
			$hash{$drugList[$i]}=$wds[3];
		close IN;
	}

	#output the drugs and scores by the order
	print "#########################################################\n";
	print "This is the prediction scores for the drug library screen\n";
	$i=1;
	foreach my $k (sort { $hash{$a} <=>  $hash{$b} } keys %hash) {
    		my $key = $k;
    		my $value = $hash{$k};
    		#print "$i\t$key\t\t\t$value\n";
    		printf "%d\t%-26s\t%-15.3f\n",$i,$key,$value;
    		$i++;
	}	
	#$ligandpdbqt = $ligand . "qt";		
	#print "bin\\vina\\vina.exe --config conf.txt\n";
	#system("bin\\vina\\vina.exe --config conf.txt");
	#$mfile=$ligandpdbqt;
	#$mfile=~s/\.pdbqt//;
	#print "mfile=$mfile\n";
	#print "($mfile . _out.pdbqt)\n";
	#msplit("$mfile" . "_out.pdbqt",$protein);
}elsif($options=~/ \-pdbparser\s+(\S+)/){
	$pdb=$1;
	parse_pdb_and_split_chains($pdb);
}elsif($options=~/ \-cif2pdb\s+(\S+)\s+(\S+)/){
	$cif=$1;
	$pdb=$2;
	cif2pdb($cif,$pdb);
}elsif($options=~/ \-addchain\s+(\S+)\s+(\S+)/){
	$pdb=$1;
	$chain=$2;
	$a="ATOM";
	$c="HETATM";
	@list=();
	open(IN,"$pdb");
		while($line=<IN>){
			chomp($line);
			if(($line=~/^$a/)||($line=~/^$c/)){
			        substr($line,21, 1) = "$chain";
				#print "$line"
			}else{
				#print "$line";
			}
			push(@list,$line);
		}
	close IN;
	
	open(OUT,">$pdb");
		for($i=0;$i<@list;$i++){
			print OUT "$list[$i]\n";
		}
	close OUT;
}elsif($options=~/ \-ssea\s+(\S+)\s+(\S+)/){
	my ($ssea_file1,$ssea_file2,$data1,$data2,$line,@res_1,@res_2,$this_score);
	my $len1;
	my $len2;
	$ss1=$1;
	$ss2=$2;
	$ssea_file1=$ss1;
	$ssea_file2=$ss2;
	$data1="";
	open(IN,"$ssea_file1")||die "can not open ";
		#@data1=<IN>;
		while($line=<IN>){
			chomp($line);
			if($line=~/^>/){
			
			}else{
				$data1=$data1 . "$line";
			}
		}
	close IN || die "can not close";
	
	$data2="";
	open(IN,"$ssea_file2")||die "can not open ";
		while($line=<IN>){
			chomp($line);
			if($line=~/^>/){
			
			}else{
				$data2=$data2 . "$line";
			}
		}
	close IN || die "can not close";
	
	chomp($data1);
	chomp($data2);
	@res_1=ssea_encoding($data1);
	@res_2=ssea_encoding($data2);
	
	$this_score=ssea_score($res_1[0],$res_1[1],$res_2[0],$res_2[1]);
	print "ssea_score=$this_score";
}elsif($options=~/ \-nwalignca\s+(\S+)/){
	$current_dir = `cd`;  # 返回当前目录
	chomp($current_dir);  # 去掉换行符
    $libdir="$current_dir\\fold";
    $blastdir="$libdir\\windb\\ncbi-blast-2.2.24";
    if($rlinux==1){
        $blastdir="$libdir\\windb\\linux\\ncbi-blast-2.2.24";
    }
    $pdbdb="$libdir\\windb\\db.seq";
    $fastaseq = $1;
    
    my $datadir = $fastaseq;   # 复制原始值
    $datadir =~ s/[^\\]*$//;   # 删除文件名部分
    $datadir =~ s/\\$//;       # 删除末尾的反斜杠,去掉末尾的反斜杠（如果有）
    $datadir = $datadir . "\\";
    $datadir =~ s/\\/\\\\/g;
    chdir "$datadir";
    
    $tmpseq = "";
    $nsequenceQ = "";
    if(!-e "$fastaseq"){
        print "$fastaseq not exist\n";
        exit();
    }else{
        open(IN,"$fastaseq");
            while($line=<IN>){
                chomp($line);
                if($line=~/^>/){
                    # pass 
                }else{
                    $tmpseq = $tmpseq . $line;
                    $nsequenceQ = $nsequenceQ . $line;
                }
            }
        close IN;
    }
    if(!-e "seq.fasta"){
        open(OUT,">seq.fasta");
            print OUT ">seq.fasta\n";
            print OUT "$tmpseq\n";
        close OUT;
        # printf "$datadir\\seq.fasta not exist\n";
        # exit();
    }
	
	# split_seq.pl 	
	my @proteins = ("");
	my $i = -1;
	my $line = "";
	my $j = 0;
	my $input = "";
	my @name=();
	my $len;
	my $count;

	open(IN,"$pdbdb")||die "can not open $pdbdb";
	while($line = <IN>){	
		if($line =~ /^>(\w+)\s+\d+/){
			push(@name,$1);	
			$i++;
			$proteins[$i] = "";
			$line="$line";
		}else{	
			chomp($line);
			$proteins[$i] = $proteins[$i] . $line;			
		}
	}
	close IN || die "can not close";

	for($i=0;$i<@proteins;$i++){	
		# $score = needleman_wunsch(uc($nsequenceQ), uc($proteins[$i]),$tNAME_WIDTH,$tPOSITION_WIDTH,$tSEQUENCE_WIDTH,$tBLANK,$gpen,$gextn,0);
        # print "$nsequenceQ\n";
        # print "###########\n";
        # print "$proteins[$i]\n";
        # $aligns= needleman_wunsch(uc($nsequenceQ), uc($proteins[$i]),$tNAME_WIDTH,$tPOSITION_WIDTH,$tSEQUENCE_WIDTH,$tBLANK,$gpen,$gextn);
        # print "$i $score\n";
        # print "$aligns\n";
        # open(OUT,">$name[$i].txt")||die "can not open";
		#	print OUT "$proteins[$i]";
		# close OUT || die "can not close";	
	}
	################## split_seq.pl ######################################
	
}
##################################### webpdb #############################
elsif($options=~/ \-webpdb\s+(\S+)/){
    $current_dir = `cd`;  # 返回当前目录
	chomp($current_dir);  # 去掉换行符
    $libdir="$current_dir\\fold";
    $blastdir="$libdir\\windb\\ncbi-blast-2.2.24";
    if($rlinux==1){
        $blastdir="$libdir\\windb\\linux\\ncbi-blast-2.2.24";
    }
    $nrdb="$libdir\\windb\\nr\\nr";
    
    # $fastaseq = $1;
    # $a = $1;
    $fastaseq = $1;
    if($fastaseq==1){
    # print "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH\n";
        if($options=~/\-3d\s+(\S+)/){
            $fastaseq = $1;
        }else{
            print "please set the -3d option\n";
            exit();
        }
    }      
    print "Running search pdb2026 database\n";
    print "Target=$fastaseq\n";
    # print "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH\n";
   
    my $datadir = $fastaseq;   # 复制原始值
    $datadir =~ s/[^\\]*$//;   # 删除文件名部分
    $datadir =~ s/\\$//;       # 删除末尾的反斜杠,去掉末尾的反斜杠（如果有）
    $datadir = $datadir . "\\";
    $datadir =~ s/\\/\\\\/g;
    chdir "$datadir";
    
    $tmpseq = "";
    if(!-e "$fastaseq"){
        print "$fastaseq not exist\n";
        exit();
    }else{
        open(IN,"$fastaseq");
            while($line=<IN>){
                chomp($line);
                if($line=~/^>/){
                    # pass 
                }else{
                    $tmpseq = $tmpseq . $line;
                }
            }
        close IN;
    }
    if(!-e "seq.fasta"){
        open(OUT,">seq.fasta");
            print OUT ">seq.fasta\n";
            print OUT "$tmpseq\n";
        close OUT;
        # printf "$datadir\\seq.fasta not exist\n";
        # exit();
    }
    webpdb_camodel();
    chdir "$current_dir";
}
##################################### psiblast_msa #######################
elsif($options=~/ \-metass\s+(\S+)/){
    $current_dir = `cd`;  # 返回当前目录
	chomp($current_dir);  # 去掉换行符
    $libdir="$current_dir\\fold";
    $blastdir="$libdir\\windb\\ncbi-blast-2.2.24";
    if($rlinux==1){
        $blastdir="$libdir\\windb\\linux\\ncbi-blast-2.2.24";
    }
    $nrdb="$libdir\\windb\\nr\\nr";
    
    $fastaseq = $1;
    
    my $datadir = $fastaseq;   # 复制原始值
    $datadir =~ s/[^\\]*$//;   # 删除文件名部分
    $datadir =~ s/\\$//;       # 删除末尾的反斜杠,去掉末尾的反斜杠（如果有）
    $datadir = $datadir . "\\";
    $datadir =~ s/\\/\\\\/g;
    chdir "$datadir";
    
    $tmpseq = "";
    if(!-e "$fastaseq"){
        print "$fastaseq not exist\n";
        exit();
    }else{
        open(IN,"$fastaseq");
            while($line=<IN>){
                chomp($line);
                if($line=~/^>/){
                    # pass 
                }else{
                    $tmpseq = $tmpseq . $line;
                }
            }
        close IN;
    }
    if(!-e "seq.fasta"){
        open(OUT,">seq.fasta");
            print OUT ">seq.fasta\n";
            print OUT "$tmpseq\n";
        close OUT;
        # printf "$datadir\\seq.fasta not exist\n";
        # exit();
    }
    psiblast_msa();
    system("copy $current_dir\\all\\* .");
    system("perl MSA2Profile.v1.2.pl psiblastmsa.txt psiblastmsa.profile");
    # system("C:\\jdk-21.0.10\\bin\\java Add_SS3stateshhhHHHsoftmaxFrequencyUsed test psiblastmsa.profile > ss.softmax1.txt");
    # system("perl softmax1.pl test psiblastmsa.profile > ss.softmax1.txt");
    # system("perl s1.pl test psiblastmsa.profile > ss.softmax1.txt");
    # system("C:\\jdk-21.0.10\\bin\\java nAdd_SS3statesTsoftmaxFrequency test psiblastmsa.profile  > ss.softmax2.txt");
    system("perl s2.pl test psiblastmsa.profile > ss.output.txt");

}   
elsif($options=~/ \-psiblastmsa\s+(\S+)/){
    $current_dir = `cd`;  # 返回当前目录
	chomp($current_dir);  # 去掉换行符
    $libdir="$current_dir\\fold";
    $blastdir="$libdir\\windb\\ncbi-blast-2.2.24";
    if($rlinux==1){
        $blastdir="$libdir\\windb\\linux\\ncbi-blast-2.2.24";
    }
    $nrdb="$libdir\\windb\\nr\\nr";
    
    $fastaseq = $1;
    
    my $datadir = $fastaseq;   # 复制原始值
    $datadir =~ s/[^\\]*$//;   # 删除文件名部分
    $datadir =~ s/\\$//;       # 删除末尾的反斜杠,去掉末尾的反斜杠（如果有）
    $datadir = $datadir . "\\";
    $datadir =~ s/\\/\\\\/g;
    chdir "$datadir";
    
    $tmpseq = "";
    if(!-e "$fastaseq"){
        print "$fastaseq not exist\n";
        exit();
    }else{
        open(IN,"$fastaseq");
            while($line=<IN>){
                chomp($line);
                if($line=~/^>/){
                    # pass 
                }else{
                    $tmpseq = $tmpseq . $line;
                }
            }
        close IN;
    }
    if(!-e "seq.fasta"){
        open(OUT,">seq.fasta");
            print OUT ">seq.fasta\n";
            print OUT "$tmpseq\n";
        close OUT;
        # printf "$datadir\\seq.fasta not exist\n";
        # exit();
    }
    psiblast_msa();
    
}

##################################### psiblast_msa #######################

##################################### webpdb #############################
elsif($options=~/ \-psiblastca\s+(\S+)/){
    $current_dir = `cd`;  # 返回当前目录
	chomp($current_dir);  # 去掉换行符
    $libdir="$current_dir\\fold";
    $blastdir="$libdir\\windb\\ncbi-blast-2.2.24";    
    $nrdb="$libdir\\windb\\nr\\nr";     
    $fastaseq = $1;
    my $datadir = "";
    if($rlinux!=1){
        $datadir = $fastaseq;   # 复制原始值
        $datadir =~ s/[^\\]*$//;   # 删除文件名部分
        $datadir =~ s/\\$//;       # 删除末尾的反斜杠,去掉末尾的反斜杠（如果有）
        $datadir = $datadir . "\\";
        $datadir =~ s/\\/\\\\/g;
        chdir "$datadir";
    }
    elsif($rlinux==1){
        $current_dir = getcwd;
        $libdir = "$current_dir/fold";
        $blastdir = "$libdir/windb/linux/ncbi-blast-2.2.24";  ##### add linux directory
        $nrdb = "$libdir/windb/nr/nr";
        $datadir = $fastaseq;
        $datadir =~ s/[^\/]*$//;   # 删除最后一个 / 之后的部分（文件名）
        $datadir =~ s/\/$//;       # 删除末尾多余的 /（如果有）
        # 这里无需再添加 /，chdir 可以接受无末尾斜杠的目录
        chdir($datadir);
        print "chdir($datadir)\n";
    } 
    
    $tmpseq = "";
    if(!-e "$fastaseq"){
        print "$fastaseq not exist\n";
        exit();
    }else{
        open(IN,"$fastaseq");
            while($line=<IN>){
                chomp($line);
                if($line=~/^>/){
                    # pass 
                }else{
                    $tmpseq = $tmpseq . $line;
                }
            }
        close IN;
    }
    if(!-e "seq.fasta"){
        open(OUT,">seq.fasta");
            print OUT ">seq.fasta\n";
            print OUT "$tmpseq\n";
        close OUT;
        # printf "$datadir\\seq.fasta not exist\n";
        # exit();
    }
    psiblast_camodel();
    
}elsif($options=~/ \-pdb\s+(\S+)/){
    $s=$1;
    print `bin\\wget.exe https://files.rcsb.org/download/$s.pdb --directory-prefix .`;
	print `bin\\wget.exe http://www.rcsb.org/pdb/files/$s.pdb.gz --directory-prefix .`;
    # -O 或 --output-document：指定下载内容的保存文件名
    print `bin\\wget.exe https://www.rcsb.org/fasta/entry/$s -O $s.fasta.txt`;

}elsif($options=~/ \-roc\s+(\S+)/){
	$data=$1;
	my($k,$roc_count,$line,@wds,$temp_key,%hash,$key,$value,@temp,$res);
	$roc_count=0;
	open(IN,"$data") || die "can not open $!";
	while($line=<IN>){
		chomp($line);
		@wds=split(/\s+/,$line);
		$temp_key = "$roc_count" . " " . "$wds[0]";
		$hash{$temp_key}=$wds[1];
		$roc_count++;
	}
	close IN || die "can not close $!";	
	
	open(OUT,">$data\.sorted_data\.txt")||die "can not open $!";
	foreach my $k (sort { $hash{$b} <=>  $hash{$a} } keys %hash) {
	    my $key = $k;
	    my $value = $hash{$k};
	    @temp=split(/\s+/,$key);
	    print OUT "$temp[1]  $value\n";;
	}
	close OUT || die "can not close $!";
	
	$res=roc($data . ".sorted_data.txt");
	#$res=`perl global_rocpoint.pl $data.sorted_data.txt`;
	print "$res";
	
	#$res=`perl rocAuc.pl $ARGV[0].sorted_data.txt`;
	$res=auc($data . ".sorted_data.txt");
	#print "$res";	
	#$res=`perl precision-recall-point.pl $ARGV[0].sorted_data.txt`;
	$res=pr($data . ".sorted_data.txt");
	print "$res";			
}elsif($options=~/ \-clustal\s+(\S+)/){
	$msq=$1;
	print(".\\bin\\align\\clustalo\\clustalo -i $msq > $msq.clustalo.txt");
	system(".\\bin\\align\\clustalo\\clustalo -i $msq > $msq.clustalo.txt");
}      

############################################################################################

my $arg_count = @ARGV;
$arg_count--;
$d3Test = 0;
$tTest = 0;
$Ligand = 0;
$webpdb = 0;
for($i=0;$i<$arg_count;$i++){
	$opt=substr($ARGV[$i+1],0,1);
	if($opt eq "-"){
		next;
	}
	if($ARGV[$i] eq "-3d"){
        $d3Test = 1;
		$fastaseq = $ARGV[$i+1];
		$current_dir = `cd`;  # 返回当前目录
		chomp($current_dir);  # 去掉换行符
		chdir "fold\\foldcenter";
        # print("perl runFold.win7.3.pl $current_dir\\fold -3d $fastaseq");
		# system("perl runFold.win7.3.pl $current_dir\\fold -3d $fastaseq");
	}
    if($ARGV[$i] eq "-t"){
        $tTest = 1;
		$t = $ARGV[$i+1];
    }
	if(($ARGV[$i] eq "-L")||($ARGV[$i] eq "-l")){
        $Ligand = 1;
		$L = $ARGV[$i+1];
    }
	
	if(($ARGV[$i] eq "-webpdb")||($ARGV[$i] eq "-WEBPDB")){
        $webpdb = 1;
		# $L = $ARGV[$i+1];
    }
}

if($d3Test==1){
    if($tTest==1){
	   if($webpdb==1){
		  # print("perl run.pl -psiblastca $fastaseq");
		  # system("perl run.pl -psiblastca $fastaseq");
		  # exit();
	   }
       print("perl runFold.pl $current_dir\\fold -3d $fastaseq -t $t -webpdb $webpdb");
	   system("perl runFold.pl $current_dir\\fold -3d $fastaseq -t $t -webpdb $webpdb");
    }else{
	   if($webpdb==1){
		  # exit();
	   }
       print("perl runFold.pl $current_dir\\fold -3d $fastaseq -webpdb $webpdb");
	   system("perl runFold.pl $current_dir\\fold -3d $fastaseq -webpdb $webpdb");
    }
}

sub calculate_aa_distribution {
    my $filename = shift or die "Usage: $0 <filename>\n";
    my @num = ();
    my @aa = ("A","C","D","E","F","G","H","I","K","L","M","N","P","Q","R","S","T","V","W","Y");
    my $seq = "";
    open(my $IN, '<', $filename) || die "Cannot open $filename: $!";
    while (my $line = <$IN>) {
        chomp($line);
        if ($line !~ /^>/) {
            $seq .= $line;
        }
    }
    close $IN;

    for (my $i = 0; $i < @aa; $i++) {
        $num[$i] = 0;
    }

    for (my $i = 0; $i < length($seq); $i++) {
        my $a = substr($seq, $i, 1);
        for (my $j = 0; $j < @aa; $j++) {
            if ($a eq $aa[$j]) {
                $num[$j]++;
                last;
            }
        }
    }

    my $len = length($seq);
    open(my $OUT, '>', "aa20distributions.txt") || die "Cannot create output file: $!";
    for (my $i = 0; $i < @aa; $i++) {
        my $score = $num[$i] / $len;
        print "$aa[$i]  $num[$i] $score\n";
        print $OUT "$aa[$i]  $num[$i] $score\n";
    }
    close $OUT;
}

sub conf{
	my $protein = $_[0];
	my $ligand = $_[1];	
	$cfile="
	receptor = $protein
	ligand = $ligand
	center_x = -22
	center_y = 16
	center_z = 83
	
	size_x = 40
	size_y = 40
	size_z = 40
	
	exhaustiveness = 8	
	";
	return $cfile; 
}

sub conf1{
my $protein = $_[0];
my $ligand = $_[1];	
$cfile="
receptor = $protein
ligand = $ligand
	
center_x = $_[2]
center_y = $_[3]
center_z = $_[4]	
	
size_x = 40
size_y = 40
size_z = 40
	
exhaustiveness = 8	
";
	
return $cfile; 
}

sub conf1cacenter{
my $protein = $_[0];
my $ligand = $_[1];	
$cfile="
receptor = $protein
ligand = $ligand
	
center_x = $_[2]
center_y = $_[3]
center_z = $_[4]	
	
size_x = 60
size_y = 60
size_z = 60
	
exhaustiveness = 8	
";
	
return $cfile; 
}

sub conflibrary{
    my $protein = $_[0];
    my $ligand = $_[1];	
    $cfile="
    receptor = $protein
    center_x = $_[2]
    center_y = $_[3]
    center_z = $_[4]	
        
    size_x = 40
    size_y = 40
    size_z = 40
        
    exhaustiveness = 8	
    ";
        
    return $cfile; 
}

sub extractPDB{
   my $pdb = $_[0];
   my $res = $_[1];
   my $num = $_[2];
   
   my $mchain = 0;
   $mchain = $_[3] if @_ > 3;  # 只有传入第4个参数时才赋值   
   
   my $x,$y,$z;
   open(IN,"$pdb")||print "can not open $pdb\n";
   my $flag=0;
AA:   while (my $line = <IN>) {
        next unless $line =~ /^ATOM/;        
        my $serial    = substr($line, 6, 5);
        my $atom_name = substr($line, 12, 4);
        my $res_name  = substr($line, 17, 3);
        my $chain_id  = substr($line, 21, 1);
        my $res_seq   = substr($line, 22, 5);        
        my $this_chain= substr($line, 21, 1);
        
        $atom_name =~ s/\s+//g;
        $res_seq =~ s/\s+//g;
        if(($res eq $res_name)&&($num==$res_seq)&&($atom_name eq "CA")){
        	$flag=1;            
            if($mchain!=0){  ##### use chain information flag
                if($this_chain ne $mchain){  #### determine the chain 
                    next AA;
                }
            }
            
        	# print "res_seq=$res_seq\n";
        	# print "atom_name=$atom_name\n";       
	        $x         = substr($line, 30, 8);
	        $y         = substr($line, 38, 8);
	        $z         = substr($line, 46, 8);      
	        $serial =~ s/\s+//g;	        
	        $res_name =~ s/\s+//g;
	        $chain_id =~ s/\s+//g;	        
	        $x =~ s/\s+//g;
	        $y =~ s/\s+//g;
	        $z =~ s/\s+//g;        
        }
        # 应用过滤条件
        #next if $options{residue} && $res_name ne $options{residue};
        #next if $options{chain} && $chain_id ne $options{chain};
        #next if $options{resnum} && $res_seq ne $options{resnum};
        #next if $options{atom} && $atom_name ne $options{atom};
        
        # 保存匹配的原子
        #push @atoms, {
        #    serial    => $serial,
        #    atom_name => $atom_name,
        #    res_name  => $res_name,
        #    chain_id  => $chain_id,
        #    res_seq   => $res_seq,
        #    x         => $x,
        #    y         => $y,
        #    z         => $z
        #};  
        #$atom_count++;
    }
    close IN;
    if($flag==0){
    	print "$res$num is not found in $pdb\n";
    }
    return ($x . " " . $y . " " . $z);
}

sub msplit{
	$mfile=$_[0];
	$prot=$_[1];
	$lig=$mfile;
	$lig=~s/_out.pdbqt//;
	my $ttfile=$prot;
	$ttfile=~s/\.pdb//g;
	$ttfile=~s/\.pdbqt//g;
	my @proteins = ("");
	my $i = -1;
	my $line = "";
	my $j = 0;
	my $input = "";
	my @name=();
	my $len;
	my $count;	
	$c="HETATM";
	$lname=$lig;
	$nlname = $lname;
	$nlname=~s/^m\.//;
	if(length($nlname)>3){
		$nlname=substr($nlname,0,3);
	}
	if(length($nlname)<=1){
		$nlname="Lig";
	}
	$lastNum=0;
	$atomLastNum=0;
	$atom="ATOM";
	$ter="Ter";
	$ter1="TER";
	$hetatm="HETATM";
	open(IN,"$prot")||die "can not open";
	     	while($line=<IN>){
	     		chomp($line);
	     		if($line=~/^$atom\s+(\d+)\s+/){
					$lastNum=substr($line,22,4);
					$atomLastNum=$1;
				}
				if(($line=~/$ter\s+(\d+)\s+/)||($line=~/$ter1\s+(\d+)\s+/)){
					if($atomLastNum<$1){
						$atomLastNum=$1;
					}
				}
				if($line=~/^$hetatm\s+(\d+)\s+/){
					$lastNum=substr($line,22,4);
					$atomLastNum=$1;
				}				
	     	}
	close IN||die "can not open";
	$lastNum=~s/\s+//g;
	$lastNum++;
	$atomLastNum=~s/\s+//g;
	$atomLastNum++;
	$Llen=length($lastNum);
	open(OUT,">temp.dat");
	open(IN,"$mfile")||die "error!";
		while($line=<IN>){
			chomp($line);
			$line=~s/^\s*$//mg;
		    $line=~s/^\s+//mg;
		    $line=~s/^\n+//mg;
		    $line=~s/^\n//mg;
		    $line=~s/^\n\n//mg;
		    $line=~s/^\n+//mg;
		    $line=~s/\n+$//;
			$len=length($line);
			if($len>=1){
				print OUT "$line\n";
			}
		}
	close IN;
	close OUT;
	
	open(IN,"temp.dat")||die "error!";
	while($line = <IN>){	
		#print "$thisApos=$atomLastNum";
		#exit();
		if($line =~ /(MODEL)\s+(\d+)/)
		{
			$thisApos=$atomLastNum;
			push(@name,$1 . $2);	
			$i++;
			$proteins[$i]="";
		}	
		if($line=~/^$c/){
			#chomp($line);
			substr($line,21, 1) = "L";			
			substr($line,17, 3) = "$nlname";
			substr($line,70, 6) = "      ";
			if($Llen==1){
				substr($line,25,1)=$lastNum;
			}elsif($Llen==2){
				substr($line,24,2)=$lastNum;
			}elsif($Llen==3){
				substr($line,23,3)=$lastNum;
			}elsif($Llen==4){
				substr($line,22,4)=$lastNum;
			}
			$alen=length($thisApos);
			if($alen==1){
				substr($line,10,1)=$thisApos;
				$thisApos++;
			}elsif($alen==2){
				substr($line,9,2)=$thisApos;
				$thisApos++;
			}elsif($alen==3){
				substr($line,8,3)=$thisApos;
				$thisApos++;
			}elsif($alen==4){
				substr($line,7,4)=$thisApos;
				$thisApos++;
			}
			#print "$line";
			$line=~s/^\s*$//mg;
		    $line=~s/^\s+//mg;
		    $line=~s/^\n+//mg;
		    $line=~s/^\n//mg;
		    $line=~s/^\n\n//mg;
		    $line=~s/^\n+//mg;
		    $line=~s/\n+$//;
		    # $proteins[$i] = $proteins[$i] . $line . "";		
			$proteins[$i] = $proteins[$i] . $line . "\n";
		}else{
			$line="";
		}		
	}
	close IN || die "can not close";	
	for($i=0;$i<@proteins;$i++){	
         my $num=$i+1;
	     $complex="complex" . $num . ".pdb";
	     open(OUT1,">$ttfile.$lig.$complex")||die "can not open";
	     open(IN,"$prot")||die "can not open";
	     	while($line=<IN>){
	     		chomp($line);
	     		print OUT1 "$line\n";
	     	}
	     close IN||die "can not open";
		 $t= "$lig" . "$name[$i].pdb";
	     open(OUT,">$t")||die "can not open";
		    print OUT "$proteins[$i]";
		    print OUT1 "$proteins[$i]";
			print OUT1 "TER\n";
	     close OUT || die "can not close";
	     close OUT1 || die "can not close";
	}
	#print "msystem=$msystem\n";
	if(-e "temp.dat"){
		if($msystem=~/$win\d+/){
			system("del temp.dat");
		}elsif(($msystem=~/$linux/)||($msystem=~/"Linux"/)){
			system("rm -rf temp.dat");
		}
	}
}

sub Lchain{
    $lig=$_[0];
    $c="HETATM";
    open(OUT,">L.pdb")||die "can not open";
    open(IN,"$lig");
        while($line=<IN>){
            if(($line=~/^$a/)||($line=~/^$c/)){
                    substr($line,21, 1) = "L";
                #substr($line,21-4, 4) = "NADH";
                print OUT "$line";
            }else{
                print OUT "$line";
            }
        }
    close IN;
    close OUT;
}

sub sst4{
    $tpdb=$_[0];
    $pdb=$tpdb;
    $pdb=~s/\.pdb//g;
    $s=$pdb;
    %three2one=('GLY'=>'G','ALA'=>'A','VAL'=>'V','LEU'=>'L','ILE'=>'I','SER'=>'S','THR'=>'T','CYS'=>'C','MET'=>'M','PRO'=>'P','ASP'=>'D','ASN'=>'N','GLU'=>'E','GLN'=>'Q','LYS'=>'K','ARG'=>'R','HIS'=>'H','PHE'=>'F','TYR'=>'Y','TRP'=>'W','ASX'=>'A','GLX'=>'G','UNK'=>'X','G'=>'GLY','A'=>'ALA','V'=>'VAL','L'=>'LEU','I'=>'ILE','S'=>'SER','T'=>'THR','C'=>'CYS','M'=>'MET','P'=>'PRO','D'=>'ASP','N'=>'ASN','E'=>'GLU','Q'=>'GLN','K'=>'LYS','R'=>'ARG','H'=>'HIS','F'=>'PHE','Y'=>'TYR','W'=>'TRP','a'=>'CYS','b'=>'CYS','c'=>'CYS','d'=>'CYS','e'=>'CYS','f'=>'CYS','g'=>'CYS','h'=>'CYS','i'=>'CYS','j'=>'CYS','k'=>'CYS','l'=>'CYS','m'=>'CYS','n'=>'CYS','o'=>'CYS','p'=>'CYS','q'=>'CYS','r'=>'CYS','s'=>'CYS','t'=>'CYS','u'=>'CYS','v'=>'CYS','w'=>'CYS','x'=>'CYS','y'=>'CYS','z'=>'CYS','B'=>'ASX','Z'=>'GLX','X'=>'CYS');
    open(OUT,">$s.ss.txt");
        printf "Input $s\.pdb\n";
        printf "Output $s\.ss.txt\n";
        printf "Output secondary structural types H: Helix, E: strand, C: coil and T: turn\n";
        printf "Relative solvent accessibility values are also given.\n";
        open(pdb,"$s\.pdb")||print "can not open $s\.pdb";
        $j=0;
        while($line=<pdb>){
            if(substr($line,0,4) eq "ATOM" && substr($line,12,4)=~/CA/){
                $j++;
                $seq{$j}=$three2one{substr($line,17,3)};
                print OUT "$seq{$j}";
            }
        }
        close(pdb);
        $Lch=$j;
        for($j=1;$j<=$Lch;$j++){
            $sec{$j}="C";
            $tsa{$j}=0;
        }
        print OUT "\n";
        
        if($msystem=~/$win\d+/){
                $sspath="bin/ss/s.exe";
        }elsif(($msystem=~/$linux/)||($msystem=~/"Linux"/)){
                $sspath="bin/ss/s.linux";
        }	        
        @lines=`$sspath $s\.pdb`;
        #`bin\\ss\\s.exe $s\.pdb > $s.stride.txt`;
        $k=0;
AC:     foreach $line(@lines){
            @wds = split(/\s+/,$line);
            if($line=~/^ASG/){
                $k++;
                $a = substr($line,24,1);
                if($a eq "H"){
                   $sec{$k}="H";
                }
                if($a eq "E"){
                   $sec{$k}="E";
                }
                if($a eq "T"){
                   $sec{$k}="T";
                }
                $len = @wds;
                $raw = $wds[$len-2];
                # print "$tsa{$k} = ssa($wds[1],$raw)\n";
                $tsa{$k} = ssa($wds[1],$raw);
            }
            if($k >= $Lch){
                last AC;
            }
        }
		$H = 0;
		$E = 0;
		$C = 0;
		$T = 0;
        for($j=1;$j<=$Lch;$j++){
            print OUT "$sec{$j}";
			if($sec{$j} eq "H"){
				$H++;
			}elsif($sec{$j} eq "E"){
				$E++;
			}elsif($sec{$j} eq "C"){
				$C++;
			}elsif($sec{$j} eq "T"){
				$T++;
			}else{
				print "secondary structure type error $sec{$j}\n";
				exit(0);
			}
        }
		$pH = $H/($H+$E+$C+$T);
		$pE = $E/($H+$E+$C+$T);
		$pC = $C/($H+$E+$C+$T);
		$pT = $T/($H+$E+$C+$T);
		
		print OUT "\n\nProportion H=$pH  E=$pE  C=$pC T=$pT\n";
		print "Proportion H=$pH  E=$pE  C=$pC T=$pT\n";
        
        print OUT "\n\n\n";
        print OUT "Relative solvent accessibility values for each residue\n";
        for($j=1;$j<=$Lch;$j++){
            print OUT "$j $tsa{$j}\n";
        }
    close OUT;    
}

sub ss{
    $tpdb=$_[0];
    $pdb=$tpdb;
    $pdb=~s/\.pdb//g;
    $s=$pdb;
    %three2one=('GLY'=>'G','ALA'=>'A','VAL'=>'V','LEU'=>'L','ILE'=>'I','SER'=>'S','THR'=>'T','CYS'=>'C','MET'=>'M','PRO'=>'P','ASP'=>'D','ASN'=>'N','GLU'=>'E','GLN'=>'Q','LYS'=>'K','ARG'=>'R','HIS'=>'H','PHE'=>'F','TYR'=>'Y','TRP'=>'W','ASX'=>'A','GLX'=>'G','UNK'=>'X','G'=>'GLY','A'=>'ALA','V'=>'VAL','L'=>'LEU','I'=>'ILE','S'=>'SER','T'=>'THR','C'=>'CYS','M'=>'MET','P'=>'PRO','D'=>'ASP','N'=>'ASN','E'=>'GLU','Q'=>'GLN','K'=>'LYS','R'=>'ARG','H'=>'HIS','F'=>'PHE','Y'=>'TYR','W'=>'TRP','a'=>'CYS','b'=>'CYS','c'=>'CYS','d'=>'CYS','e'=>'CYS','f'=>'CYS','g'=>'CYS','h'=>'CYS','i'=>'CYS','j'=>'CYS','k'=>'CYS','l'=>'CYS','m'=>'CYS','n'=>'CYS','o'=>'CYS','p'=>'CYS','q'=>'CYS','r'=>'CYS','s'=>'CYS','t'=>'CYS','u'=>'CYS','v'=>'CYS','w'=>'CYS','x'=>'CYS','y'=>'CYS','z'=>'CYS','B'=>'ASX','Z'=>'GLX','X'=>'CYS');
    open(OUT,">$s.ss.txt");
        printf "$s\.pdb\n";
        printf "Output $s\.ss.txt\n";
        printf "Output secondary structural types H: Helix, E: strand and C: coil\n";
        printf "Relative solvent accessibility values are also given.\n";
        open(pdb,"$s\.pdb")||print "can not open $s\.pdb";
        $j=0;
        while($line=<pdb>){
            if(substr($line,0,4) eq "ATOM" && substr($line,12,4)=~/CA/){
                $j++;
                $seq{$j}=$three2one{substr($line,17,3)};
                print OUT "$seq{$j}";
            }
        }
        close(pdb);
        $Lch=$j;
        for($j=1;$j<=$Lch;$j++){
            $sec{$j}="C";
            $tsa{$j}=0;
        }
        print OUT "\n";
        
        if($msystem=~/$win\d+/){
                $sspath="bin/ss/s.exe";
        }elsif(($msystem=~/$linux/)||($msystem=~/"Linux"/)){
                $sspath="bin/ss/s.linux";
        }	        
        @lines=`$sspath $s\.pdb`;
        #`bin\\ss\\s.exe $s\.pdb > $s.stride.txt`;
        $k=0;
AC:     foreach $line(@lines){
            @wds = split(/\s+/,$line);
            if($line=~/^ASG/){
                $k++;
                $a = substr($line,24,1);
                if($a eq "H"){
                   $sec{$k}="H";
                }
                if($a eq "E"){
                   $sec{$k}="E";
                }
                $len = @wds;
                $raw = $wds[$len-2];
                # print "$tsa{$k} = ssa($wds[1],$raw)\n";
                $tsa{$k} = ssa($wds[1],$raw);
            }
            if($k >= $Lch){
                last AC;
            }            
        }
		$H = 0;
		$E = 0;
		$C = 0;
        for($j=1;$j<=$Lch;$j++){
            print OUT "$sec{$j}";
			if($sec{$j} eq "H"){
				$H++;
			}elsif($sec{$j} eq "E"){
				$E++;
			}elsif($sec{$j} eq "C"){
				$C++;
			}else{
				print "secondary structure type error $sec{$j}\n";
				exit(0);
			}
        }
		$pH = $H/($H+$E+$C);
		$pE = $E/($H+$E+$C);
		$pC = $C/($H+$E+$C);
		
		print OUT "\n\nProportion H=$pH  E=$pE  C=$pC\n";
		print "Proportion H=$pH  E=$pE  C=$pC\n";
        
        print OUT "\n\n\n";
        print OUT "Relative solvent accessibility values for each residue\n";
        for($j=1;$j<=$Lch;$j++){
            print OUT "$j $tsa{$j}\n";
        }
    close OUT;    
}

sub pdb2seq{
    $tpdb=$_[0];
    $pdb=$tpdb;
    $pdb=~s/\.pdb//g;
    $s=$pdb;
    %residue_maps=('GLY'=>'G','ALA'=>'A','VAL'=>'V','LEU'=>'L','ILE'=>'I','SER'=>'S','THR'=>'T','CYS'=>'C','MET'=>'M','PRO'=>'P','ASP'=>'D','ASN'=>'N','GLU'=>'E','GLN'=>'Q','LYS'=>'K','ARG'=>'R','HIS'=>'H','PHE'=>'F','TYR'=>'Y','TRP'=>'W','ASX'=>'A','GLX'=>'G','UNK'=>'X','G'=>'GLY','A'=>'ALA','V'=>'VAL','L'=>'LEU','I'=>'ILE','S'=>'SER','T'=>'THR','C'=>'CYS','M'=>'MET','P'=>'PRO','D'=>'ASP','N'=>'ASN','E'=>'GLU','Q'=>'GLN','K'=>'LYS','R'=>'ARG','H'=>'HIS','F'=>'PHE','Y'=>'TYR','W'=>'TRP','a'=>'CYS','b'=>'CYS','c'=>'CYS','d'=>'CYS','e'=>'CYS','f'=>'CYS','g'=>'CYS','h'=>'CYS','i'=>'CYS','j'=>'CYS','k'=>'CYS','l'=>'CYS','m'=>'CYS','n'=>'CYS','o'=>'CYS','p'=>'CYS','q'=>'CYS','r'=>'CYS','s'=>'CYS','t'=>'CYS','u'=>'CYS','v'=>'CYS','w'=>'CYS','x'=>'CYS','y'=>'CYS','z'=>'CYS','B'=>'ASX','Z'=>'GLX','X'=>'CYS');
    open(OUT,">$s.seq.txt");
        printf "$s\.pdb\n";
        print OUT ">$s\n";
        open(pdb,"$s\.pdb")||print "can not open $s\.pdb";
        $j=0;
        while($line=<pdb>){
            if(substr($line,0,4) eq "ATOM" && substr($line,12,4)=~/CA/){
                $j++;
                $seq{$j}=$residue_maps{substr($line,17,3)};
                print OUT "$seq{$j}";
            }
        }
        close(pdb);
    close OUT;    
}

sub needleman_wunsch {
    # my ($seq1, $seq2,$tNAME_WIDTH,$tPOSITION_WIDTH,$tSEQUENCE_WIDTH,$tBLANK,$gap_open,$gap_extn) = @_;
    $seq1 = $_[0];
    $seq2 = $_[1];
    $tNAME_WIDTH = $_[2];
    $tPOSITION_WIDTH = $_[3];
    $tSEQUENCE_WIDTH = $_[4];
    $tBLANK = $_[5];
    $gap_open = $_[6];
    $gap_extn = $_[7];  
    $align_show = 1; #### 1: give score and align, 0: give score only    
    if (@_ == 9) {
        $align_show = $_[8];
    }    
    # 初始化BLOSUM62矩阵
    my @blos62;
    for (my $i = 0; $i <= 23; $i++) {
        for (my $j = 0; $j <= 23; $j++) {
            $blos62[$i][$j] = 0;
        }
    }
    blosum62_matrix(\@blos62);    
    my $seqW = "*ARNDCQEGHILKMFPSTWYVBZX"; ### PSSM residue order
    $seq1 = "*" . $seq1;
    $seq2 = "*" . $seq2;    
    my $len1 = length($seq1);
    my $len2 = length($seq2);    
    my @seq1;
    my @seq2;    
    # 初始化序列数组
    for (my $i = 0; $i < $len1; $i++) {
        $seq1[$i] = 0;
    }
    for (my $j = 0; $j < $len2; $j++) {
        $seq2[$j] = 0;
    }
    
    # 将序列转换为氨基酸序号
    for (my $i = 1; $i < $len1; $i++) {
        my $char1 = substr($seq1, $i, 1);
        for (my $j = 1; $j < length($seqW); $j++) {
            if ($char1 eq substr($seqW, $j, 1)) {
                $seq1[$i] = $j;
                last;
            }
        }
    }
    
    for (my $i = 1; $i < $len2; $i++) {
        my $char2 = substr($seq2, $i, 1);
        for (my $j = 1; $j < length($seqW); $j++) {
            if ($char2 eq substr($seqW, $j, 1)) {
                $seq2[$i] = $j;
                last;
            }
        }
    }
    
    # 计算得分矩阵
    my @score;
    for (my $i = 1; $i < $len1; $i++) {
        for (my $j = 1; $j < $len2; $j++) {
            $score[$i][$j] = $blos62[$seq1[$i]][$seq2[$j]];
        }
    }
    
	my @val;
    my @directoryI;
    my @VicPrivisou;
    my @HicPrivisou;
    my @justpVic;
    my @justpHic;
    my @jaligni;
    for (my $j = 0; $j <= $len2; $j++) {
        $jaligni[$j] = -1;
    }    
    # 初始化数组
    for (my $i = 0; $i <= $len1; $i++) {
        for (my $j = 0; $j <= $len2; $j++) {
            $val[$i][$j] = 0;
            $directoryI[$i][$j] = 0;
            $VicPrivisou[$i][$j] = 0;
            $HicPrivisou[$i][$j] = 0;
            $justpVic[$i][$j] = 0;
            $justpHic[$i][$j] = 0;
        }
    }
    
    # Needleman-Wunsch动态规划算法
    $val[0][0] = 0;    
    for (my $i = 1; $i < $len1; $i++) {
        $val[$i][0] = $gap_extn * $i;
        $VicPrivisou[$i][0] = $val[$i][0];
        $directoryI[$i][0] = 0;
        $justpVic[$i][0] = 1;
        $justpHic[$i][0] = $i;
    }
    
    for (my $j = 1; $j < $len2; $j++) {
        $val[0][$j] = $gap_extn * $j;
        $HicPrivisou[0][$j] = $val[0][$j];
        $directoryI[0][$j] = 0;
        $justpVic[0][$j] = $j;
        $justpHic[0][$j] = 1;
    }
    
    for (my $j = 1; $j < $len2; $j++) {
        for (my $i = 1; $i < $len1; $i++) {
            my $D = $val[$i-1][$j-1] + $score[$i][$j];
            $justpHic[$i][$j] = 1;
            my $val1 = $val[$i-1][$j] + $gap_open;
            my $val2 = $HicPrivisou[$i-1][$j] + $gap_extn;
            my $H;
            if ($val1 > $val2) {
                $H = $val1;
            }
            else {
                $H = $val2;
                if ($i > 1) {
                    $justpHic[$i][$j] = $justpHic[$i-1][$j] + 1;
                }
            }
            
            $justpVic[$i][$j] = 1;
            $val1 = $val[$i][$j-1] + $gap_open;
            $val2 = $VicPrivisou[$i][$j-1] + $gap_extn;
            my $V;
            if ($val1 > $val2) {
                $V = $val1;
            }
            else {
                $V = $val2;
                if ($j > 1) {
                    $justpVic[$i][$j] = $justpVic[$i][$j-1] + 1;
                }
            }
            
            $HicPrivisou[$i][$j] = $H;
            $VicPrivisou[$i][$j] = $V;
            
            if (($D > $H) && ($D > $V)) {
                $directoryI[$i][$j] = 1;
                $val[$i][$j] = $D;
            }
            elsif ($H > $V) {
                $directoryI[$i][$j] = 2;
                $val[$i][$j] = $H;
            }
            else {
                $directoryI[$i][$j] = 3;
                $val[$i][$j] = $V;
            }
        }
    }
    
    if($align_show==0){
        return $val[$len1-1][$len2-1];
    }
    
    # Trace back
    my $i = $len1 - 1,$j = $len2 - 1;    
    while (($i > 0) && ($j > 0)) {
        if ($directoryI[$i][$j] == 1) {  # 从对角线
            $jaligni[$j] = $i;
            $i--;
            $j--;
        }elsif ($directoryI[$i][$j] == 2) {
            my $temp1 = $justpHic[$i][$j];
            for (my $me = 1; $me <= $temp1; $me++) {
                if ($i > 0) {
                    $i--;
                }
            }
        }else{
            my $temp2 = $justpVic[$i][$j];
            for (my $me = 1; $me <= $temp2; $me++) {
                if ($j > 0) {
                    $j--;
                }
            }
        }
    }
    
    my $alignmentid = 0;
    my $alignmentali = 0;
    for (my $j = 1; $j < $len2; $j++) {
        if ($jaligni[$j] > 0) {
            my $i = $jaligni[$j];
            $alignmentali++;
            if ($seq1[$i] == $seq2[$j]) {
                $alignmentid++;
            }
        }
    }
    
    my $identity = $alignmentid * 1.0 / ($len2 - 1);
    my $fina_score = $val[$len1-1][$len2-1];    
    print "Alignment bit-score=" . $fina_score . "\n";
    print "Sequence 1 aa:" . ($len1-1) . "\n";
    print "Sequence 2 aa:" . ($len2-1) . "\n";
    print "Alignmented length:" . $alignmentali . "\n";
    print "Identical length:" . $alignmentid . "\n";    
    printf "Global sequence alignment identity=%.3f", $identity;
    print " " . $alignmentid . "/" . ($len2-1) . "\n\n";
    
    my @sequenceA=();
    my @sequenceB=();
    my @sequenceM=();    
    my $k = 0;
    $i = 1;
    $j = 1;    
    while (1) {
        if (($i >= $len1) && ($j >= $len2)) {
            last;
        }        
        if (($i >= $len1) && ($j < $len2)) {  # 序列1未比对
            $k++;
            $sequenceA[$k] = '-';
            $sequenceB[$k] = substr($seqW, $seq2[$j], 1);
            $sequenceM[$k] = ' ';
            $j++;
        }
        elsif (($i < $len1) && ($j >= $len2)) {  # 序列2未比对
            $k++;
            $sequenceA[$k] = substr($seqW, $seq1[$i], 1);
            $sequenceB[$k] = '-';
            $sequenceM[$k] = ' ';
            $i++;
        }
        elsif ($i == $jaligni[$j]) {  # 如果比对上
            $k++;
            $sequenceA[$k] = substr($seqW, $seq1[$i], 1);
            $sequenceB[$k] = substr($seqW, $seq2[$j], 1);
            if ($seq1[$i] == $seq2[$j]) {  # identical
                $sequenceM[$k] = '|';
            }
            else {
                $sequenceM[$k] = ' ';
            }
            $i++;
            $j++;
        }
        elsif ($jaligni[$j] < 0) {  # seq1 gap
            $k++;
            $sequenceA[$k] = '-';
            $sequenceB[$k] = substr($seqW, $seq2[$j], 1);
            $sequenceM[$k] = ' ';
            $j++;
        }
        elsif ($jaligni[$j] >= 0) {  #seq2 gap
            $k++;
            $sequenceA[$k] = substr($seqW, $seq1[$i], 1);
            $sequenceB[$k] = '-';
            $sequenceM[$k] = ' ';
            $i++;
        }
    }
    
    #for (my $i = 1; $i <= $k; $i++) {
    #    print $sequenceA[$i];
    #}
    #print "\n";
    
    #for (my $i = 1; $i <= $k; $i++) {
    #    print $sequenceM[$i];
    #}
    #print "\n";
    
    #for (my $i = 1; $i <= $k; $i++) {
    #    print $sequenceB[$i];
    #}
    #print "\n";
    my $seqA="";
    my $seqB="";
    my $seqM="";
    for($i=1;$i<@sequenceA;$i++){
    	$seqA=$seqA . "$sequenceA[$i]";
    }
    for($i=1;$i<@sequenceB;$i++){
    	$seqB=$seqB . "$sequenceB[$i]";
    }
    for($i=1;$i<@sequenceM;$i++){
    	$seqM=$seqM . "$sequenceM[$i]";
    }
    
    my $res=format_alignment($seqA, $seqB, $seqM, 1, 1, "Seq1","Seq2",$tNAME_WIDTH,$tPOSITION_WIDTH,$tSEQUENCE_WIDTH,$tBLANK);
    print "$res\n";
    
    return "$seqA $seqB";
}

sub smith_waterman {
    my ($seq1, $seq2,$tNAME_WIDTH,$tPOSITION_WIDTH,$tSEQUENCE_WIDTH,$tBLANK,$gap_open,$gap_extn) = @_;   
    # 初始化BLOSUM62矩阵
    my @blos62;
    for (my $i = 0; $i <= 23; $i++) {
        for (my $j = 0; $j <= 23; $j++) {
            $blos62[$i][$j] = 0;
        }
    }
    blosum62_matrix(\@blos62);
    
    my $seqW = "*ARNDCQEGHILKMFPSTWYVBZX";    ### PSSM residue order
    $seq1 = "*" . $seq1;
    $seq2 = "*" . $seq2;
    
    my $len1 = length($seq1);
    my $len2 = length($seq2);
    
    my @seq1;
    my @seq2;    
    # 初始化序列数组
    for (my $i = 0; $i < $len1; $i++) {
        $seq1[$i] = 0;
    }
    for (my $j = 0; $j < $len2; $j++) {
        $seq2[$j] = 0;
    }
    
    # 将序列转换为氨基酸序号
    for (my $i = 1; $i < $len1; $i++) {
        my $char1 = substr($seq1, $i, 1);
        for (my $j = 1; $j < length($seqW); $j++) {
            if ($char1 eq substr($seqW, $j, 1)) {
                $seq1[$i] = $j;
                last;
            }
        }
    }
    
    for (my $i = 1; $i < $len2; $i++) {
        my $char2 = substr($seq2, $i, 1);
        for (my $j = 1; $j < length($seqW); $j++) {
            if ($char2 eq substr($seqW, $j, 1)) {
                $seq2[$i] = $j;
                last;
            }
        }
    }
    
    # 计算得分矩阵
    my @score;
    for (my $i = 1; $i < $len1; $i++) {
        for (my $j = 1; $j < $len2; $j++) {
            $score[$i][$j] = $blos62[$seq1[$i]][$seq2[$j]];
        }
    }
    
	my @val;
    my @directoryI;
    my @VicPrivisou;
    my @HicPrivisou;
    my @justpVic;
    my @justpHic;
    my @jaligni;
    for (my $j = 0; $j <= $len2; $j++) {
        $jaligni[$j] = -1;
    }
    
    # 初始化数组
    for (my $i = 0; $i <= $len1; $i++) {
        for (my $j = 0; $j <= $len2; $j++) {
            $val[$i][$j] = 0;
            $directoryI[$i][$j] = 0;
            $VicPrivisou[$i][$j] = 0;
            $HicPrivisou[$i][$j] = 0;
            $justpVic[$i][$j] = 0;
            $justpHic[$i][$j] = 0;
        }
    }
    
    # Smith-Waterman动态规划算法
    $val[0][0] = 0;
    
    for (my $i = 1; $i < $len1; $i++) {
        $val[$i][0] = 0;
        $VicPrivisou[$i][0] = $val[$i][0];
        $directoryI[$i][0] = 0;
        $justpVic[$i][0] = 1;
        $justpHic[$i][0] = $i;
    }
    
    for (my $j = 1; $j < $len2; $j++) {
        $val[0][$j] = 0;
        $HicPrivisou[0][$j] = $val[0][$j];
        $directoryI[0][$j] = 0;
        $justpVic[0][$j] = $j;
        $justpHic[0][$j] = 1;
    }
    
    my $max_i = -1;
    my $max_j = -1;
    my $max_value = -1;
    
    # 动态规划
    for (my $j = 1; $j < $len2; $j++) {
        for (my $i = 1; $i < $len1; $i++) {
            my $D = $val[$i-1][$j-1] + $score[$i][$j];
            $justpHic[$i][$j] = 1;
            my $val1 = $val[$i-1][$j] + $gap_open;
            my $val2 = $HicPrivisou[$i-1][$j] + $gap_extn;
            my $H;
            if ($val1 > $val2) {
                $H = $val1;
            }
            else {
                $H = $val2;
                if ($i > 1) {
                    $justpHic[$i][$j] = $justpHic[$i-1][$j] + 1;
                }
            }
            $justpVic[$i][$j] = 1;
            $val1 = $val[$i][$j-1] + $gap_open;
            $val2 = $VicPrivisou[$i][$j-1] + $gap_extn;
            my $V;
            if ($val1 > $val2) {
                $V = $val1;
            }
            else {
                $V = $val2;
                if ($j > 1) {
                    $justpVic[$i][$j] = $justpVic[$i][$j-1] + 1;
                }
            }
            
            $HicPrivisou[$i][$j] = $H;
            $VicPrivisou[$i][$j] = $V;
            
            if ((0 >= $D) && (0 >= $H) && (0 >= $V)) {
                $directoryI[$i][$j] = 0;
            }
            elsif (($D > $H) && ($D > $V)) {
                $directoryI[$i][$j] = 1;
                $val[$i][$j] = $D;
            }
            elsif ($H > $V) {
                $directoryI[$i][$j] = 2;
                $val[$i][$j] = $H;
            }
            else {
                $directoryI[$i][$j] = 3;
                $val[$i][$j] = $V;
            }         
            # 记录最大值
            if ($val[$i][$j] > $max_value) {
                $max_value = $val[$i][$j];
                $max_i = $i;
                $max_j = $j;
            }
        }
    }
    
    # 回溯路径
    my $i = $max_i;
    my $j = $max_j;    
    while (($i > 0) && ($j > 0)) {
        if ($directoryI[$i][$j] == 0) {
            last;
        }
        
        if ($directoryI[$i][$j] == 1) {  # 从对角线
            $jaligni[$j] = $i;
            $i--;
            $j--;
        }
        elsif ($directoryI[$i][$j] == 2) {  # 从水平
            my $temp1 = $justpHic[$i][$j];
            for (my $me = 1; $me <= $temp1; $me++) {
                if ($i > 0) {
                    $i--;
                }
            }
        }
        else {  # 从垂直
            my $temp2 = $justpVic[$i][$j];
            for (my $me = 1; $me <= $temp2; $me++) {
                if ($j > 0) {
                    $j--;
                }
            }
        }
    }
    
    # 计算序列同一性
    my $alignmentid = 0;
    my $L_ali = 0;
    for (my $j = 0; $j < $len2; $j++) {
        if ($jaligni[$j] >= 0) {
            my $i = $jaligni[$j];
            $L_ali++;
            if ($seq1[$i] == $seq2[$j]) {
                $alignmentid++;
            }
        }
    }
    
    my $fina_score = $val[$max_i][$max_j];
    print "Alignment bit-score=" . $fina_score . "\n";
    
    my $identity = $alignmentid > 0 ? $alignmentid * 1.0 / $L_ali : 0;
    
    print "Sequence 1 aa:" . ($len1-1) . "\n";
    print "Sequence 2 aa:" . ($len2-1) . "\n";
    print "Aligned length:" . $L_ali . "\n";
    print "Identical length:" . $alignmentid . "\n";
    
    printf "Local sequence alignment identity=%.3f", $identity;
    print " " . $alignmentid . "/" . $L_ali . "\n\n";
    
    # 输出比对序列
    my $sequenceA = "";
    my $sequenceB = "";
    my $sequenceM = "";    
    $i = $max_i;
    $j = $max_j;    
    while (1) {
        if ($directoryI[$i][$j] == 0) {
            last;
        }
        
        if (($i >= $len1) && ($j < $len2)) {  # 序列1未比对
            $sequenceA = "-" . $sequenceA;
            $sequenceB = substr($seqW, $seq2[$j], 1) . $sequenceB;
            $sequenceM = " " . $sequenceM;
            $j--;
        }
        elsif (($i < $len1) && ($j >= $len2)) {  # 序列2未比对
            $sequenceA = substr($seqW, $seq1[$i], 1) . $sequenceA;
            $sequenceB = "-" . $sequenceB;
            $sequenceM = " " . $sequenceM;
            $i--;
        }
        elsif ($i == $jaligni[$j]) {  # 如果比对
            $sequenceA = substr($seqW, $seq1[$i], 1) . $sequenceA;
            $sequenceB = substr($seqW, $seq2[$j], 1) . $sequenceB;
            if ($seq1[$i] == $seq2[$j]) {  # 相同
                $sequenceM = "|" . $sequenceM;
            }
            else {
                $sequenceM = " " . $sequenceM;
            }
            $i--;
            $j--;
        }
        elsif ($jaligni[$j] < 0) {  # 序列1有gap
            $sequenceA = "-" . $sequenceA;
            $sequenceB = substr($seqW, $seq2[$j], 1) . $sequenceB;
            $sequenceM = " " . $sequenceM;
            $j--;
        }
        elsif ($jaligni[$j] >= 0) {  # 序列2有gap
            $sequenceA = substr($seqW, $seq1[$i], 1) . $sequenceA;
            $sequenceB = "-" . $sequenceB;
            $sequenceM = " " . $sequenceM;
            $i--;
        }
    }    
    my $res=format_alignment($sequenceA, $sequenceB, $sequenceM, $i+1, $j+1, "Seq1","Seq2",$tNAME_WIDTH,$tPOSITION_WIDTH,$tSEQUENCE_WIDTH,$tBLANK);
    print "$res\n";
}

sub format_alignment {
    my ($alignX, $alignY, $match, $startQ, $startT, $target, $template,$NAME_WIDTH,$POSITION_WIDTH,$SEQUENCE_WIDTH,$BLANK) = @_;
    my @sequence1 = split //, $alignX;
    my @sequence2 = split //, $alignY;
    my @markup = split //, $match;
    my $length = @sequence1 < @sequence2 ? @sequence1 : @sequence2;
    my $name1 = adjust_name($target, $NAME_WIDTH, $BLANK);
    my $name2 = adjust_name($template, $NAME_WIDTH, $BLANK);
    my $buffer = "";
    my $preMarkup = $BLANK x ($NAME_WIDTH + 1 + $POSITION_WIDTH + 1);
    my $position1 = $startQ;
    my $position2 = $startT;
    for (my $i = 0; $i * $SEQUENCE_WIDTH < $length; $i++) {
        my $oldPosition1 = $position1;
        my $oldPosition2 = $position2;
        my $line = (($i + 1) * $SEQUENCE_WIDTH) < $length ? ($i + 1) * $SEQUENCE_WIDTH : $length;
        my @subsequence1;
        my @subsequence2;
        my @submarkup;
        for (my $j = $i * $SEQUENCE_WIDTH, my $k = 0; $j < $line; $j++, $k++) {
            push @subsequence1, $sequence1[$j];
            push @subsequence2, $sequence2[$j];
            push @submarkup, $markup[$j];
            my $c1 = $subsequence1[$k];
            my $c2 = $subsequence2[$k];
            if ($c1 eq $c2) {
                $position1++;
                $position2++;
            } elsif ($c1 eq '-') {
                $position2++;
            } elsif ($c2 eq '-') {
                $position1++;
            } else {
                $position1++;
                $position2++;
            }
        }
        my $seq1_str = join('', @subsequence1);
        my $seq2_str = join('', @subsequence2);
        my $mark_str = join('', @submarkup);
        $buffer .= $name1 . $BLANK . adjust_position($oldPosition1, $POSITION_WIDTH, $BLANK) . $BLANK . $seq1_str . $BLANK;
        $buffer .= $position1 == 1 ? adjust_position($position1, $POSITION_WIDTH, $BLANK) : adjust_position($position1 - 1, $POSITION_WIDTH, $BLANK);
        $buffer .= "\n";
        $buffer .= $preMarkup . $mark_str . "\n";
        $buffer .= $name2 . $BLANK . adjust_position($oldPosition2, $POSITION_WIDTH, $BLANK) . $BLANK . $seq2_str . $BLANK;
        $buffer .= $position2 == 1 ? adjust_position($position2, $POSITION_WIDTH, $BLANK) : adjust_position($position2 - 1, $POSITION_WIDTH, $BLANK);
        $buffer .= "\n\n";
    }
    return $buffer;
}

sub adjust_name {
    my ($name, $width, $blank) = @_;
    if (length($name) > $width) {
        return substr($name, 0, $width);
    } else {
        return $name . ($blank x ($width - length($name)));
    }
}

sub adjust_position {
    my ($position, $width, $blank) = @_;
    my $pos_str = sprintf("%d", $position);
    if (length($pos_str) > $width) {
        return substr($pos_str, -$width);
    } else {
        return ($blank x ($width - length($pos_str))) . $pos_str;
    }
}

sub read_fasta_or_raw_sequence {
    my ($file) = @_;
    my $seq = "";
    
    unless (-e $file) {
        return $file;
    }
    
    open(my $fh, '<', $file) or die "无法打开文件: $file";
    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ /^>/) {
            # 跳过fasta头行
        }
        else {
            $line =~ s/\s//g;
            $seq .= $line;
        }
    }
    close($fh);
    
    return $seq;
}

sub read_pdb {
    my ($file) = @_;
    my $seq = "";    
    open(my $fh, '<', $file) or die "无法打开文件: $file";
    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ /^TER/) {
            last;
        }
        if ($line =~ /^ATOM/) {
            my $atom_name = substr($line, 12, 4);
            $atom_name =~ s/\s+//g;
            if ($atom_name eq "CA") {
                my $res_name = substr($line, 17, 3);
                $res_name =~ s/\s+//g;
                $seq .= name_map(uc($res_name));
            }
        }
    }
    close($fh);
    
    return $seq;
}

sub name_map {
    my ($residue) = @_;
    my %aa_map = (
        "ALA" => "A", "ARG" => "R", "ASN" => "N", "ASP" => "D",
        "CYS" => "C", "GLN" => "Q", "GLU" => "E", "GLY" => "G",
        "HIS" => "H", "ILE" => "I", "LEU" => "L", "LYS" => "K",
        "MET" => "M", "PHE" => "F", "PRO" => "P", "SER" => "S",
        "THR" => "T", "TRP" => "W", "TYR" => "Y", "VAL" => "V",
        "ASX" => "B", "GLX" => "Z", "UNK" => "X"
    );
    
    return $aa_map{$residue} || "X";
}

######################################### split chains ###################################################################
sub parse_pdb_and_split_chains {
    my ($pdb_file) = @_;
    open my $fh, '<', $pdb_file or die "无法打开文件: $pdb_file";

    my ($n_ch, $res_old, $ch_old) = (0, "zzz", "ABC");
    my (%Lch, %n_atom, %ter, %CH, %ATOM_LINES, %HAS_CA);
    my ($obslte, $theoretical) = (1, 1);

    while (my $line = <$fh>) {
        my $record = substr($line, 0, 6);

        # 检查是否为过时结构或理论模型
        $obslte = -1 if $record eq "OBSLTE";
        $theoretical = -1 if $record eq "EXPDTA" && $line =~ /THEORETIC/;

        # 处理TER或ENDMDL记录
        if ($record =~ /^TER/ || $record eq "ENDMDL") {
            for my $i (1 .. $n_ch) {
                $ter{$CH{$i}} = "yes" if $Lch{$i} > 2;
            }
        }

        # 处理ATOM记录
        if ($record eq "ATOM  " || $record eq "HETATM") {
            process_atom_line(
                $line, \%ter, \%Lch, \%n_atom, \%CH, \%ATOM_LINES, \%HAS_CA,
                \$n_ch, \$res_old, \$ch_old
            );
        }
    }
    close $fh;

    # 输出处理后的链结构
    output_chains($pdb_file, $n_ch, \%Lch, \%CH, \%ATOM_LINES, \%HAS_CA, \%n_atom, $obslte, $theoretical);
}

# 处理ATOM行
sub process_atom_line {
    my ($line, $ter_ref, $Lch_ref, $n_atom_ref, $CH_ref, $ATOM_LINES_ref, $HAS_CA_ref,
        $n_ch_ref, $res_old_ref, $ch_old_ref) = @_;

    my $ch = substr($line, 21, 1);
    
    # 检查链是否已终止
    return if defined $$ter_ref{$ch} && $$ter_ref{$ch} eq "yes";

    my $atom = substr($line, 12, 4);
    my $atom0 = $atom;
    $atom0 =~ s/\s//mg;
    my $atomH = $atom0;
    $atomH =~ s/\d//mg;
    my $H = substr($atomH, 0, 1);
    return if defined $H && $H eq "H";  # 跳过氢原子

    my $seq = substr($line, 17, 3);
    return if $seq =~ /\s+/;  # 跳过DNA

    # 将未知残基转为GLY
    $seq = 'GLY' unless is_standard_aa($seq);

    my $alt = substr($line, 16, 1);
    if ($alt eq " " || $alt eq "A" || $alt eq "1") {
        my $res = substr($line, 22, 5);

        # 新链处理
        if ($ch ne $$ch_old_ref) {
            $$n_ch_ref++;
            $$CH_ref{$$n_ch_ref} = $ch;
            $$ch_old_ref = $ch;
        }

        # 新残基处理
        if (!defined $$res_old_ref || $$res_old_ref ne $res) {
            $$Lch_ref{$$n_ch_ref}++;
            $$res_old_ref = $res;
        }

        # 保存完整的ATOM行
        my $n = ++$$n_atom_ref{$$n_ch_ref, $$Lch_ref{$$n_ch_ref}};
        $$ATOM_LINES_ref{$$n_ch_ref, $$Lch_ref{$$n_ch_ref}, $n} = $line;
        
        # 检查是否包含CA原子
        if ($atom =~ /CA/) {
            $$HAS_CA_ref{$$n_ch_ref, $$Lch_ref{$$n_ch_ref}} = 1;
        }
    }
}

# 判断是否为标准氨基酸
sub is_standard_aa {
    my ($res) = @_;
    return grep { $_ eq $res } @standard_amino_acids;
}

# 生成输出文件名
sub generate_output_filename {
    my ($input_file, $chain_id) = @_;
    
    # 提取基础文件名（不含路径和扩展名）
    my $base_name = $input_file;
    $base_name =~ s/\.pdb$//i;      # 移除.pdb扩展名
    $base_name =~ s/.*[\/\\]//;     # 移除路径
    
    # 处理链ID：空格链用下划线，其他链直接附加
    if ($chain_id eq " ") {
        return "${base_name}_.pdb";
    } else {
        return "${base_name}${chain_id}.pdb";
    }
}

# 输出各链为独立PDB文件
sub output_chains {
    my ($pdb_file, $n_ch, $Lch_ref, $CH_ref, $ATOM_LINES_ref, $HAS_CA_ref, $n_atom_ref, $obslte, $theoretical) = @_;
    return unless $n_ch > 0;
    print "输入文件: $pdb_file\n";
    print "检测到 $n_ch 条链:\n";
    
    for my $i (1 .. $n_ch) {
        my $chain_id = defined $$CH_ref{$i} ? $$CH_ref{$i} : " ";
        my $res_count = $$Lch_ref{$i};
        
        printf "  链 %d: ID='%s', 残基数=%d\n", $i, $chain_id, $res_count;
    }
    print "\n";

    for my $i (1 .. $n_ch) {
        next unless $$Lch_ref{$i} >= 30;  # 只处理长度≥30的链

        my $chain_id = defined $$CH_ref{$i} ? $$CH_ref{$i} : " ";
        my $out_file = generate_output_filename($pdb_file, $chain_id);

        open my $out_fh, '>', $out_file or die "无法写入: $out_file";

        my ($atom_count, $res_count) = (0, 0);
        
        # 输出HEADER记录
        # print $out_fh "HEADER    EXTRACTED CHAIN $chain_id FROM $pdb_file\n";
        # print $out_fh "REMARK    Generated by ProteinKits\n";
        # print $out_fh "REMARK    Original chain ID: '$chain_id'\n";
        # print $out_fh "REMARK    Residues: $$Lch_ref{$i}\n";
        
        # 按残基顺序输出所有原子
        for my $j (1 .. $$Lch_ref{$i}) {
            # 只处理包含CA原子的残基
            next unless $$HAS_CA_ref{$i, $j};
            
            my $atom_count_per_res = $$n_atom_ref{$i, $j} || 0;
            next unless $atom_count_per_res > 0;
            
            $res_count++;
            
            # 输出该残基的所有原子
            for my $k (1 .. $atom_count_per_res) {
                if (defined $$ATOM_LINES_ref{$i, $j, $k}) {
                    $atom_count++;
                    my $original_line = $$ATOM_LINES_ref{$i, $j, $k};
                    
                    # 保持原始行的完整格式，只更新原子序号和残基序号
                    my $new_line = substr($original_line, 0, 6);  # 记录名 (6字符)
                    $new_line .= sprintf("%5d", $atom_count);     # 原子序号 (5字符)
                    $new_line .= substr($original_line, 11, 1);   # 空格 (1字符)
                    $new_line .= substr($original_line, 12, 4);   # 原子名 (4字符)
                    $new_line .= substr($original_line, 16, 1);   # 交替位点 (1字符)
                    $new_line .= substr($original_line, 17, 3);   # 残基名 (3字符)
                    $new_line .= substr($original_line, 20, 1);   # 空格 (1字符)
                    $new_line .= substr($original_line, 21, 1);   # 链ID (1字符)
                    $new_line .= sprintf("%4d", $res_count);      # 残基序号 (4字符)
                    $new_line .= substr($original_line, 26, 55);  # 剩余所有信息
                    
                    print $out_fh $new_line;
                }
            }
        }
        
        print $out_fh "TER\n";
        print $out_fh "END\n";
        close $out_fh;
        print "已生成文件: $out_file (包含 $atom_count 个原子, $res_count 个残基)\n";
    }
    
    # 统计信息
    my $processed_chains = 0;
    for my $i (1 .. $n_ch) {
        $processed_chains++ if $$Lch_ref{$i} >= 30;
    }
    print "\n处理完成: 共处理 $processed_chains 条符合条件的链\n";
}
######################################### split chains ###################################################################

################################### ssea ###################################################
sub ssea_encoding{
	my (@res,$ssea_string,$len,$start_pos,$end_pos,$ss_type,$ss_len,$i,$type,$this_len);		
	$ssea_string=$_[0];
	$ssea_string=$ssea_string . "*";
	$len=length($ssea_string);
	$start_pos=0;
	$end_pos=0;
	$ss_type="";
	$ss_len="";
	for($i=0;$i<$len-1;$i++){	
		if(substr($ssea_string,$end_pos,1) eq substr($ssea_string,$end_pos+1,1)){
			$end_pos++;
		}else{		
			$type=substr($ssea_string,$end_pos,1);
			$this_len=$end_pos-$start_pos+1;			
			$ss_type=$ss_type . "$type";
			$ss_len=$ss_len . "$this_len ";
			$start_pos=$i+1;
			$end_pos=$i+1;		
		}
	}
	
	$res[0]=$ss_type;
	$res[1]=$ss_len;
	return @res;
}

sub ssea_score{	
	my ($seqA,$seqA_score_string,$seqB,$seqB_score_string,$i,$j,@matrix,$s1,$s2,$len_i,$len_j,$score,$m,$n,$ave_len,@scoreA_array,@scoreB_array);	
	my ($align_A,$align_B,$align_A_num,$align_B_num);	
	my($score1,$score2,$type1,$type2,@align_A_score,@align_B_score,$temp);
	my($align_A_extension,$align_B_extension);

	$seqA=$_[0];
	$seqA_score_string=$_[1];
	@scoreA_array=split(/\s+/,$seqA_score_string);
	$seqB=$_[2];
	$seqB_score_string=$_[3];	
	@scoreB_array=split(/\s+/,$seqB_score_string);
	$m=length($seqA);
	$n=length($seqB);	
	for($i=0;$i<=$m;$i++){
		$matrix[$i][0]=0;
	}
	for($j=0;$j<=$n;$j++){
		$matrix[0][$j]=0;
	}	
	for($i=1;$i<=$m;$i++){	
		for($j=1;$j<=$n;$j++){				
			$s1=$matrix[$i-1][$j];
			$s2=$matrix[$i][$j-1];		
		
			$score =$matrix[$i-1][$j-1] + match(substr($seqA,$i-1,1),$scoreA_array[$i-1],substr($seqB,$j-1,1),$scoreB_array[$j-1]);
			
			if($s1>$s2 && $s1>$score){
				$matrix[$i][$j]=$s1;
			}elsif($s2>$score){
				$matrix[$i][$j]=$s2;
			}else{
				$matrix[$i][$j]=$score;
			}		
		}
	}	
	$ave_len=0;
	for($i=0;$i<@scoreA_array;$i++){
		$ave_len=$ave_len+$scoreA_array[$i];
	}
	for($j=0;$j<@scoreB_array;$j++){
		$ave_len=$ave_len+$scoreB_array[$j];
	}
	$ave_len=$ave_len/2;
	$score=$matrix[$m][$n]/$ave_len;	
	
#	for($i=0;$i<=$m;$i++){	
#		for($j=0;$j<=$n;$j++){
#			print "$matrix[$i][$j]\t";
#		}
#		print "\n";
#	}

	#print "match_score=$matrix[$m][$n]\n";
	
	###  print the alignment of the secondary structure elements alignment   ###
	$i=$m;
	$j=$n;
	$align_A="";
	$align_B="";
	$align_A_num="";
	$align_B_num="";
	@align_A_score=();
	@align_B_score=();
	while($i>0){							
		do{			
			if($i==0){
				$align_A = "-" . $align_A;
				$align_B = substr($seqB,$j-1,1) . $align_B;				
				$align_A_num = " " . $align_A_num;				
				$align_B_num = "$scoreB_array[$j-1]" . $align_B_num ;
				push(@align_A_score,0);
				push(@align_B_score,$scoreB_array[$j-1]);			
				$j--;				
			}elsif($j==0){			
				$align_A = substr($seqA,$i-1,1) . $align_A;
				$align_B = "-" . $align_B;				
				$align_A_num = "$scoreA_array[$i-1]" . $align_A_num;
				$align_B_num =  " " . $align_B_num;
				push(@align_A_score,$scoreA_array[$i-1]);
				push(@align_B_score,0);			
				$i--;
			}elsif($matrix[$i][$j]==($matrix[$i-1][$j-1] + match(substr($seqA,$i-1,1),$scoreA_array[$i-1],substr($seqB,$j-1,1),$scoreB_array[$j-1]))){			

				$align_A = substr($seqA,$i-1,1) . $align_A;
				$align_B = substr($seqB,$j-1,1) . $align_B;
				
				$align_A_num = "$scoreA_array[$i-1]" . $align_A_num;
				$align_B_num = "$scoreB_array[$j-1]" . $align_B_num;
								
				push(@align_A_score,$scoreA_array[$i-1]);
				push(@align_B_score,$scoreB_array[$j-1]);	
				$i--;
				$j--;				
			}
			elsif($matrix[$i][$j]==$matrix[$i-1][$j]){
				$align_A = substr($seqA,$i-1,1) . "$align_A";
				$align_B = "-" . $align_B;
				
				$align_A_num = "$scoreA_array[$i-1]" . $align_A_num;
				$align_B_num = " " . $align_B_num;
				
				push(@align_A_score,$scoreA_array[$i-1]);
				push(@align_B_score,0);
				
				$i--;			
			}elsif($matrix[$i][$j]==$matrix[$i][$j-1]){
				$align_A = "-" . $align_A;
				$align_B = substr($seqB,$j-1,1) . $align_B;				
				$align_A_num = " " . $align_A_num;
				$align_B_num = "$scoreB_array[$j-1]" . $align_B_num;				
				push(@align_A_score,0);
				push(@align_B_score,$scoreB_array[$j-1]);				
				$j--;			
			}				
		}while($j>0);				
	}	
	print "Secondary structure elements alignment(shorten mode)\n";
	print "$align_A_num\n";
	print "$align_A\n";
	print "$align_B\n";
#	print "$align_B_num\n";
	
	###  end of the alignment of the secondary structure element             ###
	
	$j=@align_A_score;
	$j--;
	$i=0;
	while($i<$j){
		$temp=$align_A_score[$j];
		$align_A_score[$j]=$align_A_score[$i];
		$align_A_score[$i]=$temp;
		$i++;
		$j--;
	}
	
	$j=@align_B_score;
	$j--;
	$i=0;
	while($i<$j){
		$temp=$align_B_score[$j];
		$align_B_score[$j]=$align_B_score[$i];
		$align_B_score[$i]=$temp;
		$i++;
		$j--;
	}
		
	$align_A_extension = "";
	$align_B_extension = "";
	for($i=0;$i<length($align_A);$i++){
		$type1=substr($align_A,$i,1);
		$type2=substr($align_B,$i,1);
		$score1=$align_A_score[$i];
		$score2=$align_B_score[$i];
						
		if($score1>=$score2){
			for($j=0;$j<$score1;$j++){
				$align_A_extension = $align_A_extension . "$type1";
			}
			for($j=0;$j<$score2;$j++){
				$align_B_extension = $align_B_extension . "$type2";
			}
			for($j=0;$j<($score1-$score2);$j++){
				$align_B_extension = $align_B_extension . "-";
			}
		}else{
					
			for($j=0;$j<$score2;$j++){
				$align_B_extension = $align_B_extension . "$type2";
			}
			for($j=0;$j<$score1;$j++){
				$align_A_extension = $align_A_extension . "$type1";
			}
			for($j=0;$j<($score2-$score1);$j++){
				$align_A_extension = $align_A_extension . "-";
			}
					
		}		
	}	
	print "\nSecondary structure elements alignment(extension mode)\n";
	print "$align_A_extension\n";
	print "$align_B_extension\n";
	return ("$score");  
}

sub match{	
	my($type_A,$score_A,$type_B,$score_B,$len_i,$len_j,$score);	
	$type_A=$_[0];
	$score_A=$_[1];
	$type_B=$_[2];
	$score_B=$_[3];

	if($type_A eq $type_B){				
		$len_i=$score_A;
		$len_j=$score_B;
		if($len_i<$len_j){
			$score= 1*$len_i;
		}else{
			$score= 1*$len_j;
		}
	}elsif(($type_A	eq "H")	&& ($type_B eq "C")){
		$len_i=$score_A;
		$len_j=$score_B;
		if($len_i<$len_j){
			$score= 0.5*$len_i;
		}else{
			$score= 0.5*$len_j;
		}
	}elsif(($type_A	eq "C")	&& ($type_B eq "H")){
		$len_i=$score_A;
		$len_j=$score_B;
		if($len_i<$len_j){
			$score= 0.5*$len_i;
		}else{
			$score= 0.5*$len_j;
		}
	}elsif(($type_A	eq "E")	&& ($type_B eq "C")){
		$len_i=$score_A;
		$len_j=$score_B;
		if($len_i<$len_j){
			$score= 0.5*$len_i;
		}else{
			$score= 0.5*$len_j;
		}
	}elsif(($type_A	eq "C")	&& ($type_B eq "E")){
		$len_i=$score_A;
		$len_j=$score_B;
		if($len_i<$len_j){
			$score= 0.5*$len_i;
		}else{
			$score= 0.5*$len_j;
		}
	}elsif(($type_A	eq "H")	&& ($type_B eq "E")){
		$score= 0;
	}elsif(($type_A	eq "E")	&& ($type_B eq "H")){
			$score= 0;
	}
	return "$score";
}

################################### ssea ###################################################

# Algorithm 1 Generateing ROC poings
sub roc{
	my $data = $_[0];
	$file=$data;
	@R=();
	@data=();
	$n = 0;
	$p = 0;
	$file=$data;
	$dataIndex = -1;
	open(DATA,"$file") or die "can not open $file file";
	while($line=<DATA>)
	{
		chomp($line);
		if($line=~/^1\s+/){
			$p++;         # number of positive data
		}	
		elsif($line=~/^0\s+/)
		{
			$n++;         # number of negative data
		}
		else
		{
			print "$line Error\n";
			exit();
		}
		$dataIndex++;
		$data[$dataIndex]=$line;
		#print "p=$p n=$n\n";
	}
	close DATA or die "can not close data.txt file";
	$FP = 0;
	$TP = 0;
	$fpre = -1000;
	$i = 0;
	while($i<@data)
	{
		#print "data :$i: $data[$i]\n";
		@tempWords = split(/\s+/,$data[$i]);
		$fi = $tempWords[1];
		if($fi ne $fpre)
		{	$v1 = $FP/$n;
			$v2 = $TP/$p;
			push(@R,("$v1" . "," . "$v2"));
			$fpre = $fi;
		}	
		if(($tempWords[0] eq "+1")||($tempWords[0] eq "1")){
			$TP++;
		}elsif(($tempWords[0] eq "-1")||($tempWords[0] eq "0")){
			$FP++;
		}else{
			print "error ! i==$i \n";
			exit();
		}
		$i++;
	}
	$v1 = $FP/$n;
	$v2 = $TP/$p;
	push(@R,("$v1" . "," . "$v2"));
	open(OUT,">$file.points") or die "can not open result.txt";
	for($i=0;$i<scalar(@R);$i++)
	{
		print OUT "$R[$i]\n";
	}
	close OUT or die "can not close result.txt";

	$file=$file . ".points";
	open(OUT1,">$file.X")||die "can not open $!";
	open(OUT2,">$file.Y")||die "can not open $!";
	open(IN,"$file")||die "can not open $file";
	while($line=<IN>){
		chomp($line);
		$line=~s/^\s+//g;
		@words=split(/,/,$line);
		print OUT1 "$words[0]\n";
		print OUT2 "$words[1]\n";
	}
	close IN||die "can not close $!";
	close OUT1||die "can not close $!";
	close OUT2||die "can not close $!";

}

sub auc{
	$ffd=$_[0];
	my @data=();
	my $n=0;
	my $p=0;
	my $TP=0;
	my $FP=0;
	my $FPprev=0;
	my $TPprev=0;
	my $line="";
	my $A=0.0;
	my $fprev = -10000;
	my $i=0;
	my @tempWords=();
	my $fi=0;
	my $f="";

	my $dataIndex = -1;

	$f=$ffd;
	open(DATA,"$f") or die "can not open data.txt file";
	while($line=<DATA>){
		chomp($line);
		$line=~s/^\s+//g;
		if(($line=~/^\+1/)||($line=~/^1/)){
			$p++;
		}elsif(($line=~/^\-1/)||($line=~/^0/)){
			$n++;
		}else{
			print "error !\n";
			exit();
		}
		$dataIndex++;
		$data[$dataIndex]=$line;
	#	print "p==$p n==$n\n";
	}
	close DATA or die "can not close data.txt file";


	my $testLen=@data;
	print "testLen:$testLen\n";

	$FP = 0.0;
	$TP = 0.0;
	$FPprev = 0.0;
	$TPprev = 0.0;
	$A = 0.0;
	$fprev = -1000000;

	$i = 0;
	while($i<@data)      # this is important ==
	{
		@tempWords = split(/\s+/,$data[$i]);
		$fi = $tempWords[1];
	#	print "$fi \n";
		if($fi ne $fprev)
		{	
			$A = $A + TRAPE_AREA($FP,$FPprev,$TP,$TPprev);
			$fprev = $fi;
			$FPprev = $FP;
			$TPprev = $TP;	
		}
		if(($tempWords[0] eq "+1")||($tempWords[0] eq "1")){
			$TP++;
		}elsif(($tempWords[0] eq "-1")||($tempWords[0] eq "0")){
			$FP++;
		}else{
			print "data:$data[$i] error ! $data[$i]\n";
			exit();
		}
		$i++;
	}

	$A = $A + TRAPE_AREA($n,$FPprev,$p,$TPprev);

	$A = $A*1.0/($p*$n*1.0);

	print "AUC score:$A\n";
	if($A<0.5){
		print "Error !Please Check that data is sorted!\n";
	}

}

sub pr{ #### precision-recall curve
	$ffd=$_[0];
	my (@R,@data,$n,$p,$line,$FP,$TP,$fi,$fpre,$v1,$v2,@tempWords,$i,$file,$dataIndex);
	$n=0;
	$p=0;
	@precision_list=();
	@recall_list=();
	push(@precision_list,1);
	push(@recall_list,0);
	$file=$ffd;
	$dataIndex = -1;
	open(DATA,"$file") or die "can not open data.txt file";
	while($line=<DATA>){
		chomp($line);
		if(($line=~/^\+1/)||($line=~/^1/)){
			$p++;         # number of positive data
		}else{
			$n++;         # number of negative data
		}
		$dataIndex++;
		$data[$dataIndex]=$line;
	#	print "p=$p n=$n\n";
	}
	close DATA or die "can not close data.txt file";

	$FP = 0;
	$TP = 0;
	$fpre = -1000;
	$i = 0;
	while($i<@data){
	#	print "data :$i: $data[$i]\n";
		@tempWords = split(/\s+/,$data[$i]);
		$fi = $tempWords[1];
			
		if(($tempWords[0] eq "1")||($tempWords[0] eq "+1")){
			$TP++;
		}elsif(($tempWords[0] eq "0")||($tempWords[0] eq "-1")){
			$FP++;
		}else{
			print "error ! i==$i \n";
			exit();
		}
		$i++;	
		$precision=$TP/($TP+$FP);
		$recall=$TP/$p;
		push(@precision_list,$precision);
		push(@recall_list,$recall);
		$fpre = $fi;
	}
	$precision=$TP/($TP+$FP);
	$recall=$TP/$p;
	push(@precision_list,0);
	push(@recall_list,1);

	$len1=@precision_list;
	$len2=@recall_list;

	print "len1=$len1  len2=$len2\n";

	if($len1!=$len2){
		print "Error $len1!=$len2\n";
		exit();
	}

	open(OUT1,">$file.precision.points.txt.Y") or die "can not open result.txt";
	open(OUT2,">$file.recall.points.txt.X") or die "can not open result.txt";
	for($i=0;$i<@precision_list;$i++)
	{
		print OUT1 "$precision_list[$i]\n";
		print OUT2 "$recall_list[$i]\n"
	}
	close OUT1 or die "can not close result.txt";
	close OUT2;

	$AP=0;
	for($i=1;$i<@recall_list;$i++){
		$delta_recall=$recall_list[$i]-$recall_list[$i-1];
		$avg_precision=($precision_list[$i]+$precision_list[$i-1])/2;
		$AP=$AP+$delta_recall*$avg_precision;
	}
	print "Area under precision-recall curve: $AP\n";
}

sub TRAPE_AREA{
   my($X1,$X2,$Y1,$Y2,$base,$height);
   $X1=$_[0];
   $X2=$_[1];
   $Y1=$_[2];
   $Y2=$_[3];
   $base = abs($X2 - $X1);
   $height = ($Y1 + $Y2)*1.0/2.0;
   return $base*$height;
}

sub blosum62_matrix {
    my ($blsMatrix_ref) = @_;
    my @blsMatrix = @$blsMatrix_ref;
    $blsMatrix[1][1]=4; $blsMatrix[1][2]=-1; $blsMatrix[1][3]=-2; $blsMatrix[1][4]=-2; $blsMatrix[1][5]=0; $blsMatrix[1][6]=-1; $blsMatrix[1][7]=-1; $blsMatrix[1][8]=0; $blsMatrix[1][9]=-2; $blsMatrix[1][10]=-1; $blsMatrix[1][11]=-1; $blsMatrix[1][12]=-1; $blsMatrix[1][13]=-1; $blsMatrix[1][14]=-2; $blsMatrix[1][15]=-1; $blsMatrix[1][16]=1; $blsMatrix[1][17]=0; $blsMatrix[1][18]=-3; $blsMatrix[1][19]=-2; $blsMatrix[1][20]=0; $blsMatrix[1][21]=-2; $blsMatrix[1][22]=-1; $blsMatrix[1][23]=0;
    $blsMatrix[2][1]=-1; $blsMatrix[2][2]=5; $blsMatrix[2][3]=0; $blsMatrix[2][4]=-2; $blsMatrix[2][5]=-3; $blsMatrix[2][6]=1; $blsMatrix[2][7]=0; $blsMatrix[2][8]=-2; $blsMatrix[2][9]=0; $blsMatrix[2][10]=-3; $blsMatrix[2][11]=-2; $blsMatrix[2][12]=2; $blsMatrix[2][13]=-1; $blsMatrix[2][14]=-3; $blsMatrix[2][15]=-2; $blsMatrix[2][16]=-1; $blsMatrix[2][17]=-1; $blsMatrix[2][18]=-3; $blsMatrix[2][19]=-2; $blsMatrix[2][20]=-3; $blsMatrix[2][21]=-1; $blsMatrix[2][22]=0; $blsMatrix[2][23]=-1;
    $blsMatrix[3][1]=-2; $blsMatrix[3][2]=0; $blsMatrix[3][3]=6; $blsMatrix[3][4]=1; $blsMatrix[3][5]=-3; $blsMatrix[3][6]=0; $blsMatrix[3][7]=0; $blsMatrix[3][8]=0; $blsMatrix[3][9]=1; $blsMatrix[3][10]=-3; $blsMatrix[3][11]=-3; $blsMatrix[3][12]=0; $blsMatrix[3][13]=-2; $blsMatrix[3][14]=-3; $blsMatrix[3][15]=-2; $blsMatrix[3][16]=1; $blsMatrix[3][17]=0; $blsMatrix[3][18]=-4; $blsMatrix[3][19]=-2; $blsMatrix[3][20]=-3; $blsMatrix[3][21]=3; $blsMatrix[3][22]=0; $blsMatrix[3][23]=-1;
    $blsMatrix[4][1]=-2; $blsMatrix[4][2]=-2; $blsMatrix[4][3]=1; $blsMatrix[4][4]=6; $blsMatrix[4][5]=-3; $blsMatrix[4][6]=0; $blsMatrix[4][7]=2; $blsMatrix[4][8]=-1; $blsMatrix[4][9]=-1; $blsMatrix[4][10]=-3; $blsMatrix[4][11]=-4; $blsMatrix[4][12]=-1; $blsMatrix[4][13]=-3; $blsMatrix[4][14]=-3; $blsMatrix[4][15]=-1; $blsMatrix[4][16]=0; $blsMatrix[4][17]=-1; $blsMatrix[4][18]=-4; $blsMatrix[4][19]=-3; $blsMatrix[4][20]=-3; $blsMatrix[4][21]=4; $blsMatrix[4][22]=1; $blsMatrix[4][23]=-1;
    $blsMatrix[5][1]=0; $blsMatrix[5][2]=-3; $blsMatrix[5][3]=-3; $blsMatrix[5][4]=-3; $blsMatrix[5][5]=9; $blsMatrix[5][6]=-3; $blsMatrix[5][7]=-4; $blsMatrix[5][8]=-3; $blsMatrix[5][9]=-3; $blsMatrix[5][10]=-1; $blsMatrix[5][11]=-1; $blsMatrix[5][12]=-3; $blsMatrix[5][13]=-1; $blsMatrix[5][14]=-2; $blsMatrix[5][15]=-3; $blsMatrix[5][16]=-1; $blsMatrix[5][17]=-1; $blsMatrix[5][18]=-2; $blsMatrix[5][19]=-2; $blsMatrix[5][20]=-1; $blsMatrix[5][21]=-3; $blsMatrix[5][22]=-3; $blsMatrix[5][23]=-2;
    $blsMatrix[6][1]=-1; $blsMatrix[6][2]=1; $blsMatrix[6][3]=0; $blsMatrix[6][4]=0; $blsMatrix[6][5]=-3; $blsMatrix[6][6]=5; $blsMatrix[6][7]=2; $blsMatrix[6][8]=-2; $blsMatrix[6][9]=0; $blsMatrix[6][10]=-3; $blsMatrix[6][11]=-2; $blsMatrix[6][12]=1; $blsMatrix[6][13]=0; $blsMatrix[6][14]=-3; $blsMatrix[6][15]=-1; $blsMatrix[6][16]=0; $blsMatrix[6][17]=-1; $blsMatrix[6][18]=-2; $blsMatrix[6][19]=-1; $blsMatrix[6][20]=-2; $blsMatrix[6][21]=0; $blsMatrix[6][22]=3; $blsMatrix[6][23]=-1;
    $blsMatrix[7][1]=-1; $blsMatrix[7][2]=0; $blsMatrix[7][3]=0; $blsMatrix[7][4]=2; $blsMatrix[7][5]=-4; $blsMatrix[7][6]=2; $blsMatrix[7][7]=5; $blsMatrix[7][8]=-2; $blsMatrix[7][9]=0; $blsMatrix[7][10]=-3; $blsMatrix[7][11]=-3; $blsMatrix[7][12]=1; $blsMatrix[7][13]=-2; $blsMatrix[7][14]=-3; $blsMatrix[7][15]=-1; $blsMatrix[7][16]=0; $blsMatrix[7][17]=-1; $blsMatrix[7][18]=-3; $blsMatrix[7][19]=-2; $blsMatrix[7][20]=-2; $blsMatrix[7][21]=1; $blsMatrix[7][22]=4; $blsMatrix[7][23]=-1;
    $blsMatrix[8][1]=0; $blsMatrix[8][2]=-2; $blsMatrix[8][3]=0; $blsMatrix[8][4]=-1; $blsMatrix[8][5]=-3; $blsMatrix[8][6]=-2; $blsMatrix[8][7]=-2; $blsMatrix[8][8]=6; $blsMatrix[8][9]=-2; $blsMatrix[8][10]=-4; $blsMatrix[8][11]=-4; $blsMatrix[8][12]=-2; $blsMatrix[8][13]=-3; $blsMatrix[8][14]=-3; $blsMatrix[8][15]=-2; $blsMatrix[8][16]=0; $blsMatrix[8][17]=-2; $blsMatrix[8][18]=-2; $blsMatrix[8][19]=-3; $blsMatrix[8][20]=-3; $blsMatrix[8][21]=-1; $blsMatrix[8][22]=-2; $blsMatrix[8][23]=-1;
    $blsMatrix[9][1]=-2; $blsMatrix[9][2]=0; $blsMatrix[9][3]=1; $blsMatrix[9][4]=-1; $blsMatrix[9][5]=-3; $blsMatrix[9][6]=0; $blsMatrix[9][7]=0; $blsMatrix[9][8]=-2; $blsMatrix[9][9]=8; $blsMatrix[9][10]=-3; $blsMatrix[9][11]=-3; $blsMatrix[9][12]=-1; $blsMatrix[9][13]=-2; $blsMatrix[9][14]=-1; $blsMatrix[9][15]=-2; $blsMatrix[9][16]=-1; $blsMatrix[9][17]=-2; $blsMatrix[9][18]=-2; $blsMatrix[9][19]=2; $blsMatrix[9][20]=-3; $blsMatrix[9][21]=0; $blsMatrix[9][22]=0; $blsMatrix[9][23]=-1;
    $blsMatrix[10][1]=-1; $blsMatrix[10][2]=-3; $blsMatrix[10][3]=-3; $blsMatrix[10][4]=-3; $blsMatrix[10][5]=-1; $blsMatrix[10][6]=-3; $blsMatrix[10][7]=-3; $blsMatrix[10][8]=-4; $blsMatrix[10][9]=-3; $blsMatrix[10][10]=4; $blsMatrix[10][11]=2; $blsMatrix[10][12]=-3; $blsMatrix[10][13]=1; $blsMatrix[10][14]=0; $blsMatrix[10][15]=-3; $blsMatrix[10][16]=-2; $blsMatrix[10][17]=-1; $blsMatrix[10][18]=-3; $blsMatrix[10][19]=-1; $blsMatrix[10][20]=3; $blsMatrix[10][21]=-3; $blsMatrix[10][22]=-3; $blsMatrix[10][23]=-1;
    $blsMatrix[11][1]=-1; $blsMatrix[11][2]=-2; $blsMatrix[11][3]=-3; $blsMatrix[11][4]=-4; $blsMatrix[11][5]=-1; $blsMatrix[11][6]=-2; $blsMatrix[11][7]=-3; $blsMatrix[11][8]=-4; $blsMatrix[11][9]=-3; $blsMatrix[11][10]=2; $blsMatrix[11][11]=4; $blsMatrix[11][12]=-2; $blsMatrix[11][13]=2; $blsMatrix[11][14]=0; $blsMatrix[11][15]=-3; $blsMatrix[11][16]=-2; $blsMatrix[11][17]=-1; $blsMatrix[11][18]=-2; $blsMatrix[11][19]=-1; $blsMatrix[11][20]=1; $blsMatrix[11][21]=-4; $blsMatrix[11][22]=-3; $blsMatrix[11][23]=-1;
    $blsMatrix[12][1]=-1; $blsMatrix[12][2]=2; $blsMatrix[12][3]=0; $blsMatrix[12][4]=-1; $blsMatrix[12][5]=-3; $blsMatrix[12][6]=1; $blsMatrix[12][7]=1; $blsMatrix[12][8]=-2; $blsMatrix[12][9]=-1; $blsMatrix[12][10]=-3; $blsMatrix[12][11]=-2; $blsMatrix[12][12]=5; $blsMatrix[12][13]=-1; $blsMatrix[12][14]=-3; $blsMatrix[12][15]=-1; $blsMatrix[12][16]=0; $blsMatrix[12][17]=-1; $blsMatrix[12][18]=-3; $blsMatrix[12][19]=-2; $blsMatrix[12][20]=-2; $blsMatrix[12][21]=0; $blsMatrix[12][22]=1; $blsMatrix[12][23]=-1;
    $blsMatrix[13][1]=-1; $blsMatrix[13][2]=-1; $blsMatrix[13][3]=-2; $blsMatrix[13][4]=-3; $blsMatrix[13][5]=-1; $blsMatrix[13][6]=0; $blsMatrix[13][7]=-2; $blsMatrix[13][8]=-3; $blsMatrix[13][9]=-2; $blsMatrix[13][10]=1; $blsMatrix[13][11]=2; $blsMatrix[13][12]=-1; $blsMatrix[13][13]=5; $blsMatrix[13][14]=0; $blsMatrix[13][15]=-2; $blsMatrix[13][16]=-1; $blsMatrix[13][17]=-1; $blsMatrix[13][18]=-1; $blsMatrix[13][19]=-1; $blsMatrix[13][20]=1; $blsMatrix[13][21]=-3; $blsMatrix[13][22]=-1; $blsMatrix[13][23]=-1;
    $blsMatrix[14][1]=-2; $blsMatrix[14][2]=-3; $blsMatrix[14][3]=-3; $blsMatrix[14][4]=-3; $blsMatrix[14][5]=-2; $blsMatrix[14][6]=-3; $blsMatrix[14][7]=-3; $blsMatrix[14][8]=-3; $blsMatrix[14][9]=-1; $blsMatrix[14][10]=0; $blsMatrix[14][11]=0; $blsMatrix[14][12]=-3; $blsMatrix[14][13]=0; $blsMatrix[14][14]=6; $blsMatrix[14][15]=-4; $blsMatrix[14][16]=-2; $blsMatrix[14][17]=-2; $blsMatrix[14][18]=1; $blsMatrix[14][19]=3; $blsMatrix[14][20]=-1; $blsMatrix[14][21]=-3; $blsMatrix[14][22]=-3; $blsMatrix[14][23]=-1;
    $blsMatrix[15][1]=-1; $blsMatrix[15][2]=-2; $blsMatrix[15][3]=-2; $blsMatrix[15][4]=-1; $blsMatrix[15][5]=-3; $blsMatrix[15][6]=-1; $blsMatrix[15][7]=-1; $blsMatrix[15][8]=-2; $blsMatrix[15][9]=-2; $blsMatrix[15][10]=-3; $blsMatrix[15][11]=-3; $blsMatrix[15][12]=-1; $blsMatrix[15][13]=-2; $blsMatrix[15][14]=-4; $blsMatrix[15][15]=7; $blsMatrix[15][16]=-1; $blsMatrix[15][17]=-1; $blsMatrix[15][18]=-4; $blsMatrix[15][19]=-3; $blsMatrix[15][20]=-2; $blsMatrix[15][21]=-2; $blsMatrix[15][22]=-1; $blsMatrix[15][23]=-2;
    $blsMatrix[16][1]=1; $blsMatrix[16][2]=-1; $blsMatrix[16][3]=1; $blsMatrix[16][4]=0; $blsMatrix[16][5]=-1; $blsMatrix[16][6]=0; $blsMatrix[16][7]=0; $blsMatrix[16][8]=0; $blsMatrix[16][9]=-1; $blsMatrix[16][10]=-2; $blsMatrix[16][11]=-2; $blsMatrix[16][12]=0; $blsMatrix[16][13]=-1; $blsMatrix[16][14]=-2; $blsMatrix[16][15]=-1; $blsMatrix[16][16]=4; $blsMatrix[16][17]=1; $blsMatrix[16][18]=-3; $blsMatrix[16][19]=-2; $blsMatrix[16][20]=-2; $blsMatrix[16][21]=0; $blsMatrix[16][22]=0; $blsMatrix[16][23]=0;
    $blsMatrix[17][1]=0; $blsMatrix[17][2]=-1; $blsMatrix[17][3]=0; $blsMatrix[17][4]=-1; $blsMatrix[17][5]=-1; $blsMatrix[17][6]=-1; $blsMatrix[17][7]=-1; $blsMatrix[17][8]=-2; $blsMatrix[17][9]=-2; $blsMatrix[17][10]=-1; $blsMatrix[17][11]=-1; $blsMatrix[17][12]=-1; $blsMatrix[17][13]=-1; $blsMatrix[17][14]=-2; $blsMatrix[17][15]=-1; $blsMatrix[17][16]=1; $blsMatrix[17][17]=5; $blsMatrix[17][18]=-2; $blsMatrix[17][19]=-2; $blsMatrix[17][20]=0; $blsMatrix[17][21]=-1; $blsMatrix[17][22]=-1; $blsMatrix[17][23]=0;
    $blsMatrix[18][1]=-3; $blsMatrix[18][2]=-3; $blsMatrix[18][3]=-4; $blsMatrix[18][4]=-4; $blsMatrix[18][5]=-2; $blsMatrix[18][6]=-2; $blsMatrix[18][7]=-3; $blsMatrix[18][8]=-2; $blsMatrix[18][9]=-2; $blsMatrix[18][10]=-3; $blsMatrix[18][11]=-2; $blsMatrix[18][12]=-3; $blsMatrix[18][13]=-1; $blsMatrix[18][14]=1; $blsMatrix[18][15]=-4; $blsMatrix[18][16]=-3; $blsMatrix[18][17]=-2; $blsMatrix[18][18]=11; $blsMatrix[18][19]=2; $blsMatrix[18][20]=-3; $blsMatrix[18][21]=-4; $blsMatrix[18][22]=-3; $blsMatrix[18][23]=-2;
    $blsMatrix[19][1]=-2; $blsMatrix[19][2]=-2; $blsMatrix[19][3]=-2; $blsMatrix[19][4]=-3; $blsMatrix[19][5]=-2; $blsMatrix[19][6]=-1; $blsMatrix[19][7]=-2; $blsMatrix[19][8]=-3; $blsMatrix[19][9]=2; $blsMatrix[19][10]=-1; $blsMatrix[19][11]=-1; $blsMatrix[19][12]=-2; $blsMatrix[19][13]=-1; $blsMatrix[19][14]=3; $blsMatrix[19][15]=-3; $blsMatrix[19][16]=-2; $blsMatrix[19][17]=-2; $blsMatrix[19][18]=2; $blsMatrix[19][19]=7; $blsMatrix[19][20]=-1; $blsMatrix[19][21]=-3; $blsMatrix[19][22]=-2; $blsMatrix[19][23]=-1;
    $blsMatrix[20][1]=0; $blsMatrix[20][2]=-3; $blsMatrix[20][3]=-3; $blsMatrix[20][4]=-3; $blsMatrix[20][5]=-1; $blsMatrix[20][6]=-2; $blsMatrix[20][7]=-2; $blsMatrix[20][8]=-3; $blsMatrix[20][9]=-3; $blsMatrix[20][10]=3; $blsMatrix[20][11]=1; $blsMatrix[20][12]=-2; $blsMatrix[20][13]=1; $blsMatrix[20][14]=-1; $blsMatrix[20][15]=-2; $blsMatrix[20][16]=-2; $blsMatrix[20][17]=0; $blsMatrix[20][18]=-3; $blsMatrix[20][19]=-1; $blsMatrix[20][20]=4; $blsMatrix[20][21]=-3; $blsMatrix[20][22]=-2; $blsMatrix[20][23]=-1;
    $blsMatrix[21][1]=-2; $blsMatrix[21][2]=-1; $blsMatrix[21][3]=3; $blsMatrix[21][4]=4; $blsMatrix[21][5]=-3; $blsMatrix[21][6]=0; $blsMatrix[21][7]=1; $blsMatrix[21][8]=-1; $blsMatrix[21][9]=0; $blsMatrix[21][10]=-3; $blsMatrix[21][11]=-4; $blsMatrix[21][12]=0; $blsMatrix[21][13]=-3; $blsMatrix[21][14]=-3; $blsMatrix[21][15]=-2; $blsMatrix[21][16]=0; $blsMatrix[21][17]=-1; $blsMatrix[21][18]=-4; $blsMatrix[21][19]=-3; $blsMatrix[21][20]=-3; $blsMatrix[21][21]=4; $blsMatrix[21][22]=1; $blsMatrix[21][23]=-1;
    $blsMatrix[22][1]=-1; $blsMatrix[22][2]=0; $blsMatrix[22][3]=0; $blsMatrix[22][4]=1; $blsMatrix[22][5]=-3; $blsMatrix[22][6]=3; $blsMatrix[22][7]=4; $blsMatrix[22][8]=-2; $blsMatrix[22][9]=0; $blsMatrix[22][10]=-3; $blsMatrix[22][11]=-3; $blsMatrix[22][12]=1; $blsMatrix[22][13]=-1; $blsMatrix[22][14]=-3; $blsMatrix[22][15]=-1; $blsMatrix[22][16]=0; $blsMatrix[22][17]=-1; $blsMatrix[22][18]=-3; $blsMatrix[22][19]=-2; $blsMatrix[22][20]=-2; $blsMatrix[22][21]=1; $blsMatrix[22][22]=4; $blsMatrix[22][23]=-1;
    $blsMatrix[23][1]=0; $blsMatrix[23][2]=-1; $blsMatrix[23][3]=-1; $blsMatrix[23][4]=-1; $blsMatrix[23][5]=-2; $blsMatrix[23][6]=-1; $blsMatrix[23][7]=-1; $blsMatrix[23][8]=-1; $blsMatrix[23][9]=-1; $blsMatrix[23][10]=-1; $blsMatrix[23][11]=-1; $blsMatrix[23][12]=-1; $blsMatrix[23][13]=-1; $blsMatrix[23][14]=-1; $blsMatrix[23][15]=-2; $blsMatrix[23][16]=0; $blsMatrix[23][17]=0; $blsMatrix[23][18]=-2; $blsMatrix[23][19]=-1; $blsMatrix[23][20]=-1; $blsMatrix[23][21]=-1; $blsMatrix[23][22]=-1; $blsMatrix[23][23]=-1;
}

sub get_python_version {
    my $version_str = `python --version 2>&1`;
    if ($version_str =~ /Python\s+(\d+\.\d+)/) {
        my $major_version = $1;
        return $major_version >= 3 ? 3 : 2;
    }    
    return -1; 
}

sub vector_dot {
    my ($a, $b) = @_;
    my $sum = 0;
    for my $i (0..$#{$a}) {
        $sum += $a->[$i] * $b->[$i];
    }
    return $sum;
}

sub ionfinder{
    my $protein = $_[0];
    my $ion = $_[1];	
    
    $f1=0;
    $f2=0;
    @atom=();
    @zn=();
    @znLine=();
    open(IN,"$protein")||print "can not open $ARGV[0]";
    open(OUTd,">$protein.dis")||print "can open dis $ARGV[0]\n";
    @disA=();
    AA:while($line=<IN>){
            chomp($line);
            
            if($line=~/ENDMDL/){
                    last AA;
            }
            
            # if($line=~/LINK\s+CU\s+CU/){
			if($line=~/LINK\s+$ion\s+$ion/){
                $f1=1;
                #print "$line\n";
                $dis=substr($line,73,6);
                $dis=~s/\s+//g;
                if(length($dis)>=1){
                    push(@disA,$dis);
                    # print "$line distance $dis\n";
                    print OUTd "$dis\n";
                }
            }
            
            # if($line=~/^HETATM\s+\d+\s+CU\s+CU/){
			if($line=~/^HETATM\s+\d+\s+$ion\s+$ion/){
                $f2=1;
                $xyz=substr($line,30,24);
                $xyz=~s/^\s+//;
                @wds=split(/\s+/,$xyz);
                $znx=$wds[0];
                $zny=$wds[1];
                $znz=$wds[2];						
                push(@zn,"$znx  $zny   $znz");
                push(@znLine,$line);
            }
            
            if($line=~/^ATOM/){
                    $xyz=substr($line,30,24);
                    $xyz=~s/^\s+//;
                    @wds=split(/\s+/,$xyz);
                    $x=$wds[0];
                    $y=$wds[1];
                    $z=$wds[2];
                    $res=substr($line,22,5);
                    $seq=substr($line,17,3);
                    push(@atom,"$x $y  $z  $res  $seq");
            }
        }
    close IN;
    close OUTd;

    if(($f1==1)&&($f2==1)){
    #	print "YES\n";
    }

    $len=@zn;
    if($f2==0){
      exit();
    }

    $get=0;
    %hasha = ();
    for($j=0;$j<@zn;$j++){
          @wds=split(/\s+/,$zn[$j]);
          $znx=$wds[0];
          $zny=$wds[1];
          $znz=$wds[2];	
                
          for($i=0;$i<@atom;$i++){
            @wds=split(/\s+/,$atom[$i]);
            $x=$wds[0];
            $y=$wds[1];
            $z=$wds[2];
            
            $dis=sqrt(($znx-$x)*($znx-$x)+($zny-$y)*($zny-$y)+($znz-$z)*($znz-$z));
            if($dis<3.5){
              # print "Finder: $atom[$i]   dis=$dis\n";
              @wds = split(/\s+/,$atom[$i]);
              $hasha{"$wds[4]$wds[3]"} = $dis;
              # print "HHHH $wds[3] $wds[4] = $dis\n";
              $get=1;
            } 
          }
    }

    if($get==1){
      print "$protein\n";	
      open(ZOUT,">$protein.cu.txt");
        for($i=0;$i<@znLine;$i++){
            print ZOUT "$znLine[$i]\n";
        }
      close ZOUT;
    }
    
    foreach my $k (sort{ $hasha{$b} <=>  $hasha{$a} } keys %hasha) {
        my $key = $k;
        my $value = $hasha{$k};
        print "$key distance=$value\n";
    }    
}

sub MSA2PSFM{
    my $msa = $_[0];
    my $psfmoutput = $_[1];	    
    $num_seqs=0;		
	    open(IN,"$msa")||die "can not open";
			while($line=<IN>)
			{
				chomp($line);
				$num_seqs++;
				$m1=0;
				@wds=split(/\s+/,$line);
				$seq=$wds[2];
				$seq_len=length($seq);
				for($i=1;$i<=$seq_len;$i++)
				{
					$m1++;
					$q=substr($seq,$i-1,1);
					$am{$num_seqs,$i}=$q;
					if($num_seqs==1)
					{
						$a=substr($seq,$i-1,1);    
						$ref_seq{$i}=$a;   #only for check
					}
				}
			}
		close IN || die "can not close";
		
		undef %aa_count; 
		for($i=1;$i<=$seq_len;$i++){
		    for($j=1;$j<=$num_seqs;$j++){
			    $aa_count{$am{$j,$i},$i}++;
		    }
		}
			
		for($i=1;$i<=$num_seqs;$i++){
		    for($j=1;$j<=$seq_len;$j++){
                $r=0;
                foreach $A(@AMINO_ACIDS){
                    $r++ if($aa_count{$A,$j}>0);
                }
                $A=$am{$i,$j};
                $s2=$aa_count{$A,$j};
                $w1=1.0/($r*$s2);
                $weight{$i}+=$w1;
		    }
		    $total_weight+=$weight{$i};
		}
		
		for($i=1;$i<=$num_seqs;$i++){
		    $weight{$i}/=$total_weight;			
		}
		
		undef %freq;
		for($i=1;$i<=$num_seqs;$i++){
		    for($j=1;$j<=$seq_len;$j++){
                $A=$am{$i,$j};
                $freq{$j,$A}+=$weight{$i};
		    }
		}
		
		open(OUT,">$psfmoutput")||die "can not open $psfmoutput for writing";
		printf OUT "$seq_len\n";
		for($i=1;$i<=$seq_len;$i++){
		    printf OUT "%3d $ref_seq{$i} %3d",$i,$i;
		    $norm=0;
		    foreach $A(@AMINO_ACIDS){
		        $norm+=$freq{$i,$A};
		    }
		    foreach $A(@AMINO_ACIDS){
		        printf OUT "%10.7f",$freq{$i,$A}/$norm;
		    }
		    printf OUT "\n";
		}
		close(OUT);
}

sub PSSMCKSAAPEncoding{
	###   Input sequence name && PSSM file && window
    my $filename = $_[0];
    my $file_pssm = $_[1];	
	my $window = $_[2];	
	my @PSSM=();
	my @Frag=();    
	open FILE,"$file_pssm" or die "cannot open the PSSM-file $file_pssm\n";
	while(my $line=<FILE>){
		chomp($line);
		if($line=~/^\s{1,4}\d/){
			$line=~s/^\s{1,4}//;
			my @array=split(/\s+/,$line);
			push(@PSSM,[@array[0..21]]);
		}
	}
	close FILE or die "cannot close the file!$!\n";

	for(my $j=0;$j<@PSSM;$j++){
		my @temp_array=();
		my $seq="";		
		if(1) {
			if($j-$window<0 and $j+$window<=$#PSSM){
				for(my $k=$j-$window;$k<0;$k++){
					$seq.="_";					
				}
				for(my $k=0;$k<=$j+$window;$k++){
					$seq.=$PSSM[$k][1];
					push(@temp_array,[@{$PSSM[$k]}]);
				}
			}elsif($j+$window>$#PSSM and $j-$window>=0){
				for(my $k=$j-$window;$k<=$#PSSM;$k++){
					$seq.=$PSSM[$k][1];
					push(@temp_array,[@{$PSSM[$k]}]);
				}
				for(my $k=$#PSSM+1;$k<=$j+$window;$k++){
					$seq.="_";
				}
			}
			elsif($j-$window>=0 and $j+$window<=$#PSSM){
				for(my $k=$j-$window;$k<=$j+$window;$k++){
					$seq.=$PSSM[$k][1];
					push(@temp_array,[@{$PSSM[$k]}]);
				}
			}
			else {
				for(my $k=$j-$window;$k<0;$k++){
					$seq.="_";
				}
				for(my $k=0;$k<@PSSM;$k++){
					$seq.=$PSSM[$k][1];
					push(@temp_array,[@{$PSSM[$k]}]);
				}
				for(my $k=@PSSM;$k<=$j+$window;$k++){
					$seq.="_";
				}
			}
				
			$seq.=".frag";
			push(@Frag,$seq);
			
			open FILE_frag,">$seq" or die "cannot open the file!$!\n";
			$seq=~s/\.frag//;
			print FILE_frag "$seq\n";
			for(my $k=0;$k<@temp_array;$k++){
				for(my $k1=0;$k1<@{$temp_array[$k]};$k1++){
					print FILE_frag "$temp_array[$k][$k1]\t";
				}
				print FILE_frag "\n";
			}
			close FILE_frag or die "cannot close the file!$!\n";			
		}			
	}

	my @sequence=();
	my $seq_1="";

	open FILE,"$filename" or die "cannot open the sequence file!$!\n";
	while(my $line=<FILE>)
	{
		chomp($line);
		next if($line=~/^>/);
		$seq_1.=$line;	
	}
	close FILE or die "cannot close the file!$!\n";

	my @array_1=$seq_1=~/[ABCDEFGHIJKLMNOPQRSTUVWXYZ]/gi;
	#my @array_1=$seq_1=~/[ACDEFGHIKLMNPQRSTVWY]/gi;
	#print "@array_1\n";
	#print join("\n",@Frag);

	my $testname="test_".$filename.".PSSMCKSAAP.txt";
	push(@Frag,$testname);


	open FILE,">$testname" or die "cannot open the file SVM file\n";

	for(my $i=0;$i<@array_1;$i++){
		#if($array_1[$i] eq 'K' or $array_1[$i] eq 'k'){		
		
		if(1){
			if($i-$window<0 and $i+$window<=$#array_1){
				for(my $k=$i-$window;$k<0;$k++){
					print FILE "_";
				}
				for(my $k=0;$k<=$i+$window;$k++){
					print FILE "$array_1[$k]";
				}
			}
			
			if($i-$window<0 and $i+$window>$#array_1){
				for(my $k=$i-$window;$k<0;$k++){
					print FILE "_";
				}
				for(my $k=0;$k<=@array_1;$k++){
					print FILE "$array_1[$k]";
				}
				for(my $k=@array_1;$k<=$i+$window;$k++){
					print FILE "_";
				}
			}
			
			if($i-$window>=0 and $i+$window<=$#array_1){
				for(my $k=$i-$window;$k<=$i+$window;$k++){
					print FILE "$array_1[$k]";
				}
			}
			
			if($i-$window>=0 and $i+$window>$#array_1){
				for(my $k=$i-$window;$k<=$#array_1;$k++){
					print FILE "$array_1[$k]";
				}
				for(my $k=@array_1;$k<=$i+$window;$k++){
					print FILE "_";
				}
			}
			printf FILE "\t%d\t1\n",$i+1;	
		}	
	}
	close FILE or die "cannot close the file!$!\n";

	PSSM_CKSAAP($testname);
	# my $name_another="SVM_".$testname;
	# push(@Frag,$name_another);
	system("del *.frag");	
}

sub min{
        my ($num1,$num2)=@_;
        my $min=$num1;
        if($num1<=$num2){
                $min=$num1;
        }else{
                $min=$num2;
        }
        return $min;
}

sub PSSM_CKSAAP{
	my $filename=$_[0];
	my @array_zuhe=qw(0 1 2 3 4 5);
	my %AA=qw(0 A 1 R 2 N 3 D 4 C 5 Q 6 E 7 G 8 H 9 I 10 L 11 K 12 M 13 F 14 P 15 S 16 T 17 W 18 Y 19 V);
	my @aminoArray=qw(A C D E F G H I K L M N P Q R S T V W Y);
	open FILE,"$filename" or die "cannot open the file!$!\n";
	open FILE_svm,">SVM_$filename" or die "cannot open the file!$!\n";
	while(my $line=<FILE>){
        chomp($line);
        $line=~s/[\r\n]//g;
        my @temp=split(/\t/,$line);
        my $dir="./";
        if($temp[2] == 1){
            print FILE_svm "";                
        }
        else {
            print FILE_svm "";                
        }

        my $name=$temp[0].".frag";
        my @lenArray=$temp[0]=~/[ABCDEFGHIJKLMNOPQRSTUVWXYZ]/g;
        my $len_seq=@lenArray;
        my @PSSM=();

        ######## 把矩阵文件读入@PSSM
        open FILE_frag,"$name" or die "cannot open the file!$!\n";
        my $line1=<FILE_frag>;
        while($line1=<FILE_frag>){
            chomp($line1);
            $line1=~s/[\r\n]//g;
            my @array=split(/\t/,$line1);
            push(@PSSM,[@array[2..$#array]]);
        }
        close FILE_frag or die "cannot close the file!$!\n";
        my $m=1;
        for(my $i=0;$i<@array_zuhe;$i++){
            ######## 初始化氨基酸对数组
            my %aminoPairs=();
            for(my $j=0;$j<@aminoArray;$j++){
				for(my $k=0;$k<@aminoArray;$k++){
					my $pairs=$aminoArray[$j].$aminoArray[$k];
                    $aminoPairs{$pairs}=0;
				}
			}
			my $len1;
			for(my $j=0;$j<$#PSSM-$array_zuhe[$i];$j++){
				$len1=$len_seq-$array_zuhe[$i]-1;
				my $k=$j+$array_zuhe[$i]+1;
				for(my $j1=0;$j1<@{$PSSM[$j]};$j1++){
					next if($PSSM[$j][$j1]<0);
					for(my $k1=0;$k1<@{$PSSM[$k]};$k1++){
						next if($PSSM[$k][$k1]<0);
						my $ap=$AA{$j1}.$AA{$k1};
						$aminoPairs{$ap}+=min($PSSM[$j][$j1],$PSSM[$k][$k1]);
					}
				}
			}

			foreach(sort(keys(%aminoPairs))){
				printf FILE_svm "$m:%.4f  ",$aminoPairs{$_}/$len1;
				$m++;
			}
		}
		print FILE_svm "\n";
	}
	close FILE_svm or die "cannot close the file!$!\n";
	close FILE or die "cannot close the file!$!\n";	
}

sub ssa{	##### calculate relative solvent accessibility of a residue
	$aa = $_[0];
	$raw_sa = $_[1];
    # print "$rsa=$raw_sa/$SA3{$aa} \n";
	$rsa=$raw_sa/$SA3{$aa};
	if($rsa>1){
		$rsa = 1;
	}
	return $rsa;
}

sub mcc{
	$tp = $_[0]; $fp = $_[1]; $tn = $_[2]; $fn = $_[3];
	print "tp=$tp fp=$fp  tn=$tn  fn=$fn\n";
	$ac=($tp+$tn)/($tp+$fp+$tn+$fn);
	$sn=$tp/($tp+$fn);
	$sp=$tn/($tn+$fp);
	$mcc=($tp*$tn-$fn*$fp)/sqrt(($tp+$fn)*($tn+$fp)*($tp+$fp)*($tn+$fn));
	return $mcc;
}

sub cif2pdb{
	$cif_file = $_[0]; 
	$pdb_out = $_[1];
	open my $cif, '<', $cif_file or die "无法打开CIF: $!";
	open my $pdb, '>', $pdb_out or die "无法写入PDB: $!";

	my %pos;
	my $in_atom = 0;
	my $atom_serial = 1;

	while (<$cif>) {
		chomp;
		# 读取字段定义
		if (/^_atom_site\./) {
			$in_atom = 1;
			if (/^_atom_site\.(\S+)/) {
				my $key = $1;
				$pos{$key} = scalar keys %pos;
			}
			next;
		}

		# 退出原子区块
		if ($in_atom && (/^#/ || /^\s*$/)) {
			$in_atom = 0;
			next;
		}

		# 解析原子行
		if ($in_atom && %pos && !/^_atom_site/) {
			my @data = split /\s+/;
			my $atom = $data[$pos{label_atom_id}];
			my $res  = $data[$pos{label_comp_id}];
			my $chain= $data[$pos{label_asym_id}];
			my $seq  = $data[$pos{label_seq_id}];
			my $x    = $data[$pos{Cartn_x}];
			my $y    = $data[$pos{Cartn_y}];
			my $z    = $data[$pos{Cartn_z}];
			my $occ  = $data[$pos{occupancy}];
			my $b    = $data[$pos{B_iso_or_equiv}];
			my $elem = $data[$pos{type_symbol}];

			# ===================== 修复警告：把 . 转为 0 =====================
			$seq = 0 if $seq eq '.';
			$occ = 0 if $occ eq '.';
			$b   = 0 if $b   eq '.';

			# 输出标准 PDB
			printf $pdb "ATOM  %5d %-4s %3s %1s%4d    %8.3f%8.3f%8.3f%6.2f%6.2f          %2s\n",
				$atom_serial++, $atom, $res, $chain, $seq,
				$x, $y, $z, $occ, $b, $elem;
		}
	}

	print $pdb "END\n";
	close $cif;
	close $pdb;
	print "output PDB: $pdb_out\n";
}

sub cacenter{
	my $pdb_file = $_[0];
	open my $fh, "<", $pdb_file or die "无法打开文件: $!";
	# 存储所有 CA 坐标的数组
	# 每个元素是：[x, y, z]
	my @a;
	my @xlist = ();
	my @ylist = ();
	my @zlist = ();
	# 逐行读取 PDB
	while (<$fh>) {
		chomp;
		next unless /^ATOM/;  # 只处理 ATOM 行

		# 提取 原子名 (PDB 格式第 13-16 列)
		my $atom_name = substr($_, 12, 4);
		$atom_name =~ s/\s+//g;  # 去掉空格

		# 只保留 CA 原子
		if ($atom_name eq 'CA') {
			# 提取坐标 x, y, z (第 31-38, 39-46, 47-54 列)
			my $x = substr($_, 30, 8);
			my $y = substr($_, 38, 8);
			my $z = substr($_, 46, 8);
			
			# 清理空格并转数字
			$x += 0; $y += 0; $z += 0;

			# 存入数组 a
			push @a, [$x, $y, $z];
			push(@xlist,$x);
			push(@ylist,$y);
			push(@zlist,$z);
		}
	}
	close $fh;
	
	$xall = 0;
	$yall = 0;
	$zall = 0;
	for($i=0;$i<@xlist;$i++){
		$xall = $xall + $xlist[$i];
		$yall = $yall + $ylist[$i];
		$zall = $zall + $zlist[$i];
	}
	$len = @xlist;
	$xall = $xall/$len;
	$yall = $yall/$len;
	$zall = $zall/$len;
	$center = "$xall $yall $zall";
	return $center;	
}

# 使用示例
# 定义两个数组引用
# my @array1 = (1.0, 2.0, 3.0, 4.0, 5.0);
# my @array2 = (2.0, 4.0, 6.0, 8.0, 10.0);
# 调用函数
# my $correlation = PearsonCorrelationCoefficient(\@array1, \@array2);
# print "Pearson correlation coefficient: $correlation\n";
sub PearsonCorrelationCoefficient {
    my ($vectors_1, $vectors_2) = @_;    
    my $x2 = 0;
    my $y2 = 0;
    my $xy = 0;
    my $s_x = 0;
    my $s_y = 0;
    
    for my $i (0 .. $#{$vectors_1}) {
        $x2 += $vectors_1->[$i] * $vectors_1->[$i];
        $y2 += $vectors_2->[$i] * $vectors_2->[$i];
        $xy += $vectors_1->[$i] * $vectors_2->[$i];
        $s_x += $vectors_1->[$i];
        $s_y += $vectors_2->[$i];
    }
    
    my $n = scalar @{$vectors_1};
    my $numerator = $n * $xy - $s_x * $s_y;
    my $denominator = sqrt(($n * $x2 - $s_x * $s_x) * ($n * $y2 - $s_y * $s_y));
    return $numerator / $denominator;
}

# psiblast_camodel();
sub webpdb_camodel{
    $sequenceQ = "";
	open(IN,"seq.fasta");
		while($line=<IN>){
			chomp($line);
			if($line=~/^>/){
				# pass
			}else{
				$sequenceQ = $sequenceQ . $line;
			}
		}
	close IN;

	$Lch = length($sequenceQ);
	for($i=1;$i<=$Lch;$i++){
		$a=substr($sequenceQ,$i-1,1);
		$seqQ{$i}=$a;
	}

	system("$blastdir\\bin\\psiblast -query seq.fasta -db $nrdb -out psiblast_output.txt -out_pssm my_profile.pssm -num_iterations 3 -evalue 0.001 -inclusion_ethresh 0.005");
	# system("$blastdir\\bin\\psiblast -in_pssm my_profile.pssm -db $libdir\\windb\\db.seq -out psiblast_output.txt -evalue 0.001 -num_iterations 1");
    # system("$blastdir\\bin\\psiblast -in_pssm my_profile.pssm -db $libdir\\windb\\wdb.fasta -out psiblast_output.txt -evalue 0.001 -num_iterations 1");
	system("$blastdir\\bin\\psiblast -in_pssm my_profile.pssm -db $libdir\\windb\\pdb2026.fasta -out psiblast_output.txt -evalue 0.001 -num_iterations 1");
	@sequenceQ = ();
	@sequenceT = ();
	@startQ    = ();
	@startT    = ();
	@evalue = ();
	$countQ = -1;
	$countT = -1;
	$i = -1;
	$line = "";
	$j = 0;
	$input = "";
	@name=();
	$len;
	@wds;
	$frag_count = -1;
	open(IN,"psiblast_output.txt")||die "can not open psiblast_output.txt";
	while($line=<IN>){	
		if($line=~/^>\s+(\w+)/){
			push(@name,$1);	
			$i++;
			$sequenceQ[$i] = "";	
			$sequenceT[$i] = "";
			$startQ[$i]    = "";
			$startT[$i]    = "";
			$countQ = -1;
			$countT = -1;
			$frag_count = -1;
		}	
		if($line=~/Expect\s+=/){
			$frag_count++;
			if($frag_count<1){
				$line=~s/^\s+//g;
				@wds = split(/\s+/,$line);
				$evalue[$i]=$wds[2];
				$evalue[$i]=~s/\,//g;
			}
		}
		if(($line=~/^Query\s+/)&&($frag_count<1)){
			$countQ++;
			@wds = split(/\s+/,$line);
			if($countQ==0){			
				$startQ[$i] = $wds[1];
			}
			$sequenceQ[$i] = $sequenceQ[$i] . $wds[2];
		}
		elsif(($line=~/^Sbjct\s+/)&&($frag_count<1)){
			$countT++;
			@wds = split(/\s+/,$line);
			if($countT==0){			
				$startT[$i] = $wds[1];
			}
			$sequenceT[$i] = $sequenceT[$i] . $wds[2];
		}		
	}
	close IN || die "can not close";

	$templatenum=0;
	open(OUT,">psiblast.txt");
	AA:for($i=0;$i<@name;$i++){ 
		$template_name = $name[$i];
		if(-e "template.pdb"){
			system("del template.pdb");
		}
		
		$this_name = substr($template_name,0,4);
		$s=$this_name;
		print `$libdir\\bin\\wget.exe https://files.rcsb.org/download/$s.pdb --directory-prefix .`;
		print `$libdir\\bin\\wget.exe http://www.rcsb.org/pdb/files/$s.pdb.gz --directory-prefix .`;
		# -O 或 --output-document：指定下载内容的保存文件名
		print `$libdir\\bin\\wget.exe https://www.rcsb.org/fasta/entry/$s -O $s.fasta.txt`;
		$pdb="$s.pdb";
		parse_pdb_and_split_chains($pdb);		
		print "template_name = $template_name\n";		
		if(-e "$template_name\.pdb"){
			system("copy $template_name\.pdb template.pdb");
            # system("copy $template_name\.pdb $libdir\\PDB\\");
            # system("copy $template_name\.pdb $libdir\\PDB\\");
		}else{
			next AA;
		}		
		# if(-e "$libdir\\PDB\\$template_name\.pdb"){
		#	system("copy $libdir\\PDB\\$template_name\.pdb template.pdb");
		# }else{
		#	print "$libdir\\PDB\\$template_name\.pdb not exist\n";
		# }	
		$templatenum++;		
		if($templatenum>20){
			last AA;
		}	
		PSIBLAST_model($startT[$i],$sequenceT[$i],$startQ[$i],$sequenceQ[$i],$template_name,$evalue[$i]);
	}
	close OUT;

	open(OUT,">psiblast.atom.dat");
		printf OUT "%5d %5d (templates, length)\n",$templatenum,$Lch;
		open(IN,"psiblast.txt");
			while($line=<IN>){
				print OUT "$line";
			}
		close IN;
	close(OUT);
}

sub psiblast_msa{
	$sequenceQ = "";
	open(IN,"seq.fasta");
		while($line=<IN>){
			chomp($line);
			if($line=~/^>/){
				# pass
			}else{
				$sequenceQ = $sequenceQ . $line;
			}
		}
	close IN;

	$Lch = length($sequenceQ);
	for($i=1;$i<=$Lch;$i++){
		$a=substr($sequenceQ,$i-1,1);
		$seqQ{$i}=$a;
	}
	system("$blastdir\\bin\\psiblast -query seq.fasta -db $nrdb -out psiblast_output.txt -out_pssm my_profile.pssm -num_iterations 3 -evalue 0.001 -inclusion_ethresh 0.005");
	system("$blastdir\\bin\\psiblast  -num_alignments 2000 -in_pssm my_profile.pssm -out_ascii_pssm seq.ascii_pssm -db $nrdb -out psiblast_output.txt -evalue 0.001 -num_iterations 1");
	@sequenceQ = ();
	@sequenceT = ();
	@startQ    = ();
	@startT    = ();
	@evalue = ();
	$countQ = -1;
	$countT = -1;
	$i = -1;
	$line = "";
	$j = 0;
	$input = "";
	@name=();
	$len;
	@wds;
	$frag_count = -1;
	open(IN,"psiblast_output.txt")||die "can not open psiblast_output.txt";
	while($line=<IN>){	
		if($line=~/^>\s+(\w+)/){
			push(@name,$1);	
			$i++;
			$sequenceQ[$i] = "";	
			$sequenceT[$i] = "";
			$startQ[$i]    = "";
			$startT[$i]    = "";
			$countQ = -1;
			$countT = -1;
			$frag_count = -1;
		}	
		if($line=~/Expect\s+=/){
			$frag_count++;
			if($frag_count<1){
				$line=~s/^\s+//g;
				@wds = split(/\s+/,$line);
				$evalue[$i]=$wds[2];
				$evalue[$i]=~s/\,//g;
			}
		}
		if(($line=~/^Query\s+/)&&($frag_count<1)){
			$countQ++;
			@wds = split(/\s+/,$line);
			if($countQ==0){			
				$startQ[$i] = $wds[1];
			}
			$sequenceQ[$i] = $sequenceQ[$i] . $wds[2];
		}
		elsif(($line=~/^Sbjct\s+/)&&($frag_count<1)){
			$countT++;
			@wds = split(/\s+/,$line);
			if($countT==0){			
				$startT[$i] = $wds[1];
			}
			$sequenceT[$i] = $sequenceT[$i] . $wds[2];
		}		
	}
	close IN || die "can not close";

	$templatenum=0;
	open(OUT,">psiblastmsa.txt");
    print OUT "Query $sequenceQ\n";
	AA:for($i=0;$i<@name;$i++){ 
		$template_name = $name[$i];
		if($templatenum>20){  ##### use 20 templates from PSI-BLAST search
			# last AA;
		}	
        $templatenum++;	
		# PSIBLAST_model($startT[$i],$sequenceT[$i],$startQ[$i],$sequenceQ[$i],$template_name,$evalue[$i]);
        # print OUT "startQ=$startQ[$i],$sequenceQ[$i]\n";
        # print OUT "startT=$startT[$i],$sequenceT[$i]\n";
        $s = "";
        for($j=1;$j<$startQ[$i];$j++){
            $s = $s . "-";
        }
        for($j=0;$j<length($sequenceQ[$i]);$j++){
            $aq = substr($sequenceQ[$i],$j,1);
            $at = substr($sequenceT[$i],$j,1);
            if($aq ne "-"){
                $s = $s . $at;
            }
        }
        if(length($s)<length($sequenceQ)){
            $len1 = length($s);
            $len2 = length($sequenceQ);
            for($j=$len1;$j<$len2;$j++){
                $s = $s . "-";
            }
        }
        print OUT "$name[$i] $s\n";
        #print OUT "$s\n";
    }
	close OUT;

}

sub psiblast_camodel{
	$sequenceQ = "";
	open(IN,"seq.fasta");
		while($line=<IN>){
			chomp($line);
			if($line=~/^>/){
				# pass
			}else{
				$sequenceQ = $sequenceQ . $line;
			}
		}
	close IN;

	$Lch = length($sequenceQ);
	for($i=1;$i<=$Lch;$i++){
		$a=substr($sequenceQ,$i-1,1);
		$seqQ{$i}=$a;
	}

    if($rlinux==1){
        print("$blastdir/bin/psiblast -query seq.fasta -db $nrdb -out psiblast_output.txt -out_pssm my_profile.pssm -num_iterations 3 -evalue 0.001 -inclusion_ethresh 0.005");
        print("$blastdir/bin/psiblast -in_pssm my_profile.pssm -db $libdir/windb/db.seq -out psiblast_output.txt -evalue 0.001 -num_iterations 1");   
        system("$blastdir/bin/psiblast -query seq.fasta -db $nrdb -out psiblast_output.txt -out_pssm my_profile.pssm -num_iterations 3 -evalue 0.001 -inclusion_ethresh 0.005");
        system("$blastdir/bin/psiblast -in_pssm my_profile.pssm -db $libdir/windb/db.seq -out psiblast_output.txt -evalue 0.001 -num_iterations 1");
    }else{
        system("$blastdir\\bin\\psiblast -query seq.fasta -db $nrdb -out psiblast_output.txt -out_pssm my_profile.pssm -num_iterations 3 -evalue 0.001 -inclusion_ethresh 0.005");
        system("$blastdir\\bin\\psiblast -in_pssm my_profile.pssm -db $libdir\\windb\\db.seq -out psiblast_output.txt -evalue 0.001 -num_iterations 1");
	}
    @sequenceQ = ();
	@sequenceT = ();
	@startQ    = ();
	@startT    = ();
	@evalue = ();
	$countQ = -1;
	$countT = -1;
	$i = -1;
	$line = "";
	$j = 0;
	$input = "";
	@name=();
	$len;
	@wds;
	$frag_count = -1;
	open(IN,"psiblast_output.txt")||die "can not open psiblast_output.txt";
	while($line=<IN>){	
		if($line=~/^>\s+(\w+)/){
			push(@name,$1);	
			$i++;
			$sequenceQ[$i] = "";	
			$sequenceT[$i] = "";
			$startQ[$i]    = "";
			$startT[$i]    = "";
			$countQ = -1;
			$countT = -1;
			$frag_count = -1;
		}	
		if($line=~/Expect\s+=/){
			$frag_count++;
			if($frag_count<1){
				$line=~s/^\s+//g;
				@wds = split(/\s+/,$line);
				$evalue[$i]=$wds[2];
				$evalue[$i]=~s/\,//g;
			}
		}
		if(($line=~/^Query\s+/)&&($frag_count<1)){
			$countQ++;
			@wds = split(/\s+/,$line);
			if($countQ==0){			
				$startQ[$i] = $wds[1];
			}
			$sequenceQ[$i] = $sequenceQ[$i] . $wds[2];
		}
		elsif(($line=~/^Sbjct\s+/)&&($frag_count<1)){
			$countT++;
			@wds = split(/\s+/,$line);
			if($countT==0){			
				$startT[$i] = $wds[1];
			}
			$sequenceT[$i] = $sequenceT[$i] . $wds[2];
		}		
	}
	close IN || die "can not close";

	$templatenum=0;
	open(OUT,">psiblast.txt");
	AA:for($i=0;$i<@name;$i++){ 
		$template_name = $name[$i];
		if(-e "template.pdb"){
			system("del template.pdb");
		}
        if($rlinux!=1){  ##### windows OS
            if(-e "$libdir\\PDB\\$template_name\.pdb"){
                system("copy $libdir\\PDB\\$template_name\.pdb template.pdb");
            }else{
                print "$libdir\\PDB\\$template_name\.pdb not exist\n";
            }				
        }else{          #### linux OS
            if (-e "$libdir/PDB/$template_name.pdb") {
                system("cp $libdir/PDB/$template_name.pdb template.pdb");
            } else {
                print "$libdir/PDB/$template_name.pdb not exist\n";
            }
        }
		if($templatenum>20){  ##### use 20 templates from PSI-BLAST search
			last AA;
		}	
        $templatenum++;	
		PSIBLAST_model($startT[$i],$sequenceT[$i],$startQ[$i],$sequenceQ[$i],$template_name,$evalue[$i]);
	}
	close OUT;

	open(OUT,">psiblast.atom.dat");
		printf OUT "%5d %5d (templates, length)\n",$templatenum,$Lch;
		open(IN,"psiblast.txt");
			while($line=<IN>){
				print OUT "$line";
			}
		close IN;
	close(OUT);
}

sub PSIBLAST_model{
	$start_t_pos = $_[0];
	$sequenceT   = $_[1];
	$start_q_pos = $_[2];
	$sequenceQ   = $_[3];
	$template_name= $_[4]; 
	$score        = $_[5];
	$sequenceT=~s/\*//mg;
    $sequenceQ=~s/\*//mg;
    $sequenceT=~s/\s+//g;
    $sequenceQ=~s/\s+//g; 	
	$L=length($sequenceQ);
	$ksame=0; 
	$Lalignment=0;
	for($j=1;$j<=$L;$j++){
		$a=substr($sequenceQ,$j-1,1);
		$b=substr($sequenceT,$j-1,1);
		if($a ne "-" && $b ne "-"){
		    $Lalignment++;
		    if($a eq $b){
                $ksame++;
		    }
		}
	}
	$identity=$ksame/($Lalignment+0.000001);
	open(IN,"template.pdb");
        $pos=0;
    	while($line=<IN>){
            $start=substr($line,0,4);
            $ca=substr($line,12,4);
            $ca=~s/\s//mg;
            if($start eq "ATOM" && $ca eq "CA"){
                $pos++;
                $seqT{$pos}=$threetoone{substr($line,17,3)};
                $numT{$pos}=substr($line,22,4);
                $x{$pos}=substr($line,30,8);
                $y{$pos}=substr($line,38,8);
                $z{$pos}=substr($line,46,8);
            }
    	}
    close(IN);
    
    $chainid = "";
    $a=substr($template_name,0,4);
    if(length($template_name)==4){
			$chainid = "_";
    }else{
			$chainid = substr($template_name,4,1);
			$chainid = ~tr/a-z/A-Z/;
    }    	
    $tname="$a$chainid";
	$template_name=~s/\\\./\./mg;
	$zscore_value=1;
	printf OUT "%5d %8.3f %5d   %6s %8.3f %8.3f(=$Lalignment/$Lch) (Lalignment,Z-score,i,pdb,identity,coverage)\n",	
	$Lalignment,$score,$templatenum,$template_name,$identity,$Lalignment/$Lch;	
	$iQ=0;
	$iT=0;
	for($j=1;$j<=length($sequenceQ);$j++){
		$sQ=substr($sequenceQ,$j-1,1);
		$sT=substr($sequenceT,$j-1,1);		
		if($sQ eq "-"){
		    $iT++;
		}
		
		if($sT eq "-"){
		    $iQ++;
		}
		
		if($sQ ne "-" && $sT ne "-"){
		    $iQ++;
		    $iT++;		    
		    printf OUT "ATOM  %5s  CA  %3s  %4d    %8.3f%8.3f%8.3f%5s %3s\n",
		    $iQ+$templatenum*1000,$threetoone{$sQ},$iQ+$start_q_pos-1,$x{$iT+$start_t_pos-1},$y{$iT+$start_t_pos-1},$z{$iT+$start_t_pos-1},$numT{$iT+$start_t_pos-1},$threetoone{$sT};		    
		    if($sQ ne $seqQ{$iQ+$start_q_pos-1} || $sT ne $seqT{$iT+$start_t_pos-1}){
                print "$tname : $iQ - $sQ = $seqQ{$iQ+$start_q_pos-1} not equal $iT - $sT = $seqT{$iT+$start_t_pos-1}\n";
		    }    
		}
	 }
	 printf OUT "TER\n";
}

# my $result = PP_value('A');
# print $result;  # 输出对应字符串
sub PP_value {
    my $a = shift;  # 获取传入的字符
    if ($a eq 'A') {
        return "1.28   0.05    1.00   0.31    6.11    0.42     0.23";
    } elsif ($a eq 'G') {
        return "0.00   0.00    0.00   0.00    6.07    0.13     0.15";
    } elsif ($a eq 'V') {
        return "3.67   0.14    3.00   1.22    6.02    0.27     0.49";
    } elsif ($a eq 'L') {
        return "2.59   0.19    4.00   1.70    6.04    0.39     0.31";
    } elsif ($a eq 'I') {
        return "4.19   0.19    4.00   1.80    6.04    0.30     0.45";
    } elsif ($a eq 'F') {
        return "2.94   0.29    5.89   1.79    5.67    0.30     0.38";
    } elsif ($a eq 'Y') {
        return "2.94   0.30    6.47   0.96    5.66    0.25     0.41";
    } elsif ($a eq 'W') {
        return "3.21   0.41    8.08   2.25    5.94    0.32     0.42";
    } elsif ($a eq 'T') {
        return "3.03   0.11    2.60   0.26    5.60    0.21     0.36";
    } elsif ($a eq 'S') {
        return "1.31   0.06    1.60   -0.04   5.70    0.20     0.28";
    } elsif ($a eq 'R') {
        return "2.34   0.29    6.13   -1.01   10.74   0.36     0.25";
    } elsif ($a eq 'K') {
        return "1.89   0.22    4.77   -0.99   9.99    0.32     0.27";
    } elsif ($a eq 'H') {
        return "2.99   0.23    4.66   0.13    7.69    0.27     0.30";
    } elsif ($a eq 'D') {
        return "1.60   0.11    2.78   -0.77   2.95    0.25     0.20";
    } elsif ($a eq 'E') {
        return "1.56   0.15    3.78   -0.64   3.09    0.42     0.21";
    } elsif ($a eq 'N') {
        return "1.60   0.13    2.95   -0.60   6.52    0.21     0.22";
    } elsif ($a eq 'Q') {
        return "1.56   0.18    3.95   -0.22   5.65    0.36     0.25";
    } elsif ($a eq 'M') {
        return "2.35   0.22    4.43   1.23    5.71    0.38     0.32";
    } elsif ($a eq 'P') {
        return "2.67   0.00    2.72   0.72    6.80    0.13     0.34";
    } elsif ($a eq 'C') {
        return "1.77   0.13    2.43   1.54    6.35    0.17     0.41";
    } else {
        return "0000";
    }
}

sub get_amino_acid_atoms {
    my $aa = shift;    
    # 标准化输入：转大写，如果是单字母则转为三字母
    $aa = uc($aa);    
    # 单字母到三字母的映射
    my %one_to_three = (
        'A' => 'ALA', 'R' => 'ARG', 'N' => 'ASN', 'D' => 'ASP',
        'C' => 'CYS', 'E' => 'GLU', 'Q' => 'GLN', 'G' => 'GLY',
        'H' => 'HIS', 'I' => 'ILE', 'L' => 'LEU', 'K' => 'LYS',
        'M' => 'MET', 'F' => 'PHE', 'P' => 'PRO', 'S' => 'SER',
        'T' => 'THR', 'W' => 'TRP', 'Y' => 'TYR', 'V' => 'VAL'
    );
    
    # 如果是单字母，转换为三字母
    if (length($aa) == 1 && exists $one_to_three{$aa}) {
        $aa = $one_to_three{$aa};
    }
    
    # 氨基酸原子数据
    my %aa_atoms = (
        'ALA' => ['N', 'CA', 'C', 'O', 'CB'],
        'ARG' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'CD', 'NE', 'CZ', 'NH1', 'NH2'],
        'ASN' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'OD1', 'ND2'],
        'ASP' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'OD1', 'OD2'],
        'CYS' => ['N', 'CA', 'C', 'O', 'CB', 'SG'],
        'GLN' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'CD', 'OE1', 'NE2'],
        'GLU' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'CD', 'OE1', 'OE2'],
        'GLY' => ['N', 'CA', 'C', 'O'],
        'HIS' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'ND1', 'CD2', 'CE1', 'NE2'],
        'ILE' => ['N', 'CA', 'C', 'O', 'CB', 'CG1', 'CG2', 'CD1'],
        'LEU' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'CD1', 'CD2'],
        'LYS' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'CD', 'CE', 'NZ'],
        'MET' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'SD', 'CE'],
        'PHE' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'CD1', 'CD2', 'CE1', 'CE2', 'CZ'],
        'PRO' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'CD'],
        'SER' => ['N', 'CA', 'C', 'O', 'CB', 'OG'],
        'THR' => ['N', 'CA', 'C', 'O', 'CB', 'OG1', 'CG2'],
        'TRP' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'CD1', 'CD2', 'NE1', 'CE2', 'CE3', 'CZ2', 'CZ3', 'CH2'],
        'TYR' => ['N', 'CA', 'C', 'O', 'CB', 'CG', 'CD1', 'CD2', 'CE1', 'CE2', 'CZ', 'OH'],
        'VAL' => ['N', 'CA', 'C', 'O', 'CB', 'CG1', 'CG2']
    );
    
    # 检查氨基酸是否存在
    if (!exists $aa_atoms{$aa}) {
        die "Error: Unknown amino acid '$aa'\n";
    }
    
    # 返回原子列表
    return @{$aa_atoms{$aa}};
    
    # 使用示例
    # my @atoms = get_amino_acid_atoms('ALA');
    # print "ALA atoms: @atoms\n";

    # @atoms = get_amino_acid_atoms('A');  # 也支持单字母
    # print "A (ALA) atoms: @atoms\n";

    # @atoms = get_amino_acid_atoms('LYS');
    # print "LYS atoms: @atoms\n";
}

sub get_propensities {
    # Propensity parameters from Costantini et al. (2006) Table 1.
    # Order: [Pa (Helix), Pb (Strand), Pc (Coil)]
    my %propensities = (
        'A' => [1.39, 0.75, 0.80], 'R' => [1.17, 0.91, 0.91], 
        'N' => [0.77, 0.62, 1.39], 'D' => [0.89, 0.55, 1.33],
        'C' => [0.74, 1.31, 1.05], 'Q' => [1.29, 0.76, 0.89],
        'E' => [1.35, 0.72, 0.86], 'G' => [0.47, 0.65, 1.62],
        'H' => [0.92, 0.99, 1.07], 'I' => [1.04, 1.71, 0.59],
        'L' => [1.32, 1.10, 0.68], 'K' => [1.11, 0.83, 1.00],
        'M' => [1.21, 0.99, 0.83], 'F' => [1.01, 1.43, 0.76],
        'P' => [0.50, 0.44, 1.72], 'S' => [0.82, 0.85, 1.24],
        'T' => [0.76, 1.23, 1.07], 'V' => [0.91, 1.86, 0.64],
        'W' => [1.06, 1.30, 0.79], 'Y' => [0.95, 1.50, 0.78]
    );
    # 使用示例：
    # my $props = get_propensities();
    # my $ala_prop = $props->{'A'};  # 返回 [1.39, 0.75, 0.80]
    # my $helix_prop = $props->{'A'}[0];  # 返回 1.39 (Helix)
    # my $strand_prop = $props->{'A'}[1];  # 返回 0.75 (Strand)
    # my $coil_prop = $props->{'A'}[2];    # 返回 0.80 (Coil)
    return \%propensities;
}

sub run_consensus_prediction{ ##### smooth the SS prediction
    my ($sequence, $propensities) = @_;    
    my $L = length($sequence);
    my $window = 3;
    my @raw_ss;    
    # 1. Sliding Window Summation
    for my $i (0 .. $L-1) {
        my @scores = (0.0, 0.0, 0.0);        
        for my $j ($i - $window .. $i + $window) {
            if ($j >= 0 && $j < $L) {
                my $aa = substr($sequence, $j, 1);
                my $props = $propensities->{$aa} || [0.33, 0.33, 0.33];
                $scores[0] += $props->[0];
                $scores[1] += $props->[1];
                $scores[2] += $props->[2];
            }
        }
        
        my $max_val = max(@scores);
        my $state_idx = 0;
        for my $k (0 .. 2) {
            if ($scores[$k] == $max_val) {
                $state_idx = $k;
                last;
            }
        }
        
        my @states = ('H', 'E', 'C');
        push @raw_ss, $states[$state_idx];
    }
    
    # 2. Smoothing
    my $ss_str = join("", @raw_ss);
    
    # Rule: Helix (H) must be at least 4 residues long
    while ($ss_str =~ /(H+)/g) {
        my $match = $1;
        my $start = pos($ss_str) - length($match);
        if (length($match) < 4) {
            substr($ss_str, $start, length($match)) = 'C' x length($match);
        }
        pos($ss_str) = $start + 1;
    }
    
    # Rule: Sheet (E) must be at least 3 residues long
    while ($ss_str =~ /(E+)/g) {
        my $match = $1;
        my $start = pos($ss_str) - length($match);
        if (length($match) < 3) {
            substr($ss_str, $start, length($match)) = 'C' x length($match);
        }
        pos($ss_str) = $start + 1;
    }
    
    return $ss_str;
}

# 创建一个新的向量
sub vector3d_new {
    my ($x, $y, $z) = @_;
    return { x => $x, y => $y, z => $z };
}

# 向量加法
sub vector3d_add {
    my ($v1, $v2) = @_;
    return vector3d_new(
        $v1->{x} + $v2->{x},
        $v1->{y} + $v2->{y},
        $v1->{z} + $v2->{z}
    );
}

# 向量叉积
sub vector3d_cross {
    my ($v1, $v2) = @_;
    return vector3d_new(
        $v1->{y} * $v2->{z} - $v1->{z} * $v2->{y},
        $v1->{z} * $v2->{x} - $v1->{x} * $v2->{z},
        $v1->{x} * $v2->{y} - $v1->{y} * $v2->{x}
    );
}

# 向量模的平方
sub vector3d_mod2 {
    my ($v) = @_;
    return $v->{x}**2 + $v->{y}**2 + $v->{z}**2;
}

# 获取向量坐标
sub vector3d_get_coords {
    my ($v) = @_;
    return ($v->{x}, $v->{y}, $v->{z});
}

# 向量转字符串
sub vector3d_to_string {
    my ($v) = @_;
    return sprintf("(%d, %d, %d)", $v->{x}, $v->{y}, $v->{z});
}

# 四舍五入辅助函数
sub _round {
    my ($value) = @_;
    return int($value + 0.5);
}
