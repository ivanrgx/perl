#!/usr/bin/perl -w
use strict;

# Proyecto final de dispositivosO
# Programa que regresa el sentido magn�tico teorico (+ o -) que debera guardarse en un disco magnetico
# de una entrada especifica en ascii
# El sentido magnatico dependera de la cadena de entrada y metodo de codificacion

# NOTA: Se tomara como sentido + el campo que precede a la parte del disco magnetico donde se grabaria la informacion


# Variables
my $string_in;								# Cadena de entrada
my $bin_data_in;							# Dato binario de entrada
my $tmp="+";								  # Variable temporal para guardar polaridad anterior
my $sentido;							  	# Sentido de la polaridad para cierto patron de bits
my $pattern;							  	# Patron de bits a buscar (Se usa en RLL)
my @salida;								  	# Arreglo para guardar el sentido de los campos magn�ticos
my @bin_data_in;							# Arreglo para los bits de entrada



# Se obtiene dato de entrada
data_in();
# Ejecucion de codificaciones
codificacion_NRZI();
codificacion_FM();
codificacion_MFM();
codificacion_RLL();




sub print_arr{
	foreach my $el (@_){
		print "$el ";
	}
	print"\n";
}


sub data_in{
	print ("Ingresar dato de entrada\n");
	$string_in = <STDIN>;
	chomp($string_in);

	$bin_data_in = join '', map{substr unpack('B8'), 1} split //, $string_in;

	#Se checa que el dato sea valido

	unless($bin_data_in=~ /^[01]+$/){
		die "Dato de entrada invalido, unicamente ingresar 0's y 1's\n\n";
	}

	@bin_data_in = split(//,$bin_data_in);

}


sub codificacion_NRZI{

	# Metodo de codificacion: Non-Return-to-Zero-Inverted (NRZI)
	# simply encodes a 1 as a magnetic polarity transition, also known as a "flux reversal", and a zero as no transition.


	foreach my $char (@bin_data_in){
		# Dependiendo de el bit de entrada, es que se determinara el sentido del campo magnetico
	    # que se guardar� en el disco magnetico;
		if($char eq "1" and $tmp eq "+"){
			$sentido = "-";
		}
		elsif($char eq "1" and $tmp eq "-"){
			$sentido = "+";
		}
		elsif($char eq "0" and $tmp eq "+"){
			$sentido = "+";
		}
		elsif($char eq "0" and $tmp eq "-"){
			$sentido = "-";
		}

		# Se guarda el sentido en el arreglo @salida
		push (@salida, $sentido);

		# Para determinar los cambios de polaridad (T o NT) se guarda el sentido de esta iteracion en $tmp
		$tmp = $sentido;
	}

	# Imprime salida que se guardaria en el disco magnetico

	print "\nDato entrada: $bin_data_in\n";
	print "\n";
	print "Codificacion NRZI:\n";
	print_arr(@salida);

}

sub codificacion_FM{

	#Metodo de codificacion: FM
	# Data	# Encoded
	# 0	     T N
	# 1	     T T

	$tmp = "+";
	@salida=();
	foreach my $char (@bin_data_in){
		if ($char eq "1" and $tmp eq "+"){
			$sentido = "-+";
		}
		elsif($char eq "1" and $tmp eq "-"){
			$sentido = "+-";
		}
		elsif($char eq "0" and $tmp eq "+"){
			$sentido = "--";
		}
		elsif($char eq "0" and $tmp eq "-"){
			$sentido = "++";
		}

		# Se guarda el sentido en el arreglo @salida
		push (@salida, $sentido);

		# Para determinar los cambios de polaridad (T o NT) se guarda el sentido de esta iteracion en $tmp
		$tmp = substr($sentido,1,1);
	}


	print "\nCodificacion FM:\n";
	print_arr(@salida);

}


sub codificacion_MFM{
	#Metodo de codificacion: MFM		Suponemos que se encuentra un 0 en el disco antes de ingresar informacion
	# Data			    # Encoded
	# 1		                N T
	# 0 precedido por 0	  T N
	# 0 precedido por 1	  N N

	$tmp = "+";
	my $bit_pre = "0";
	@salida=();
	foreach my $char (@bin_data_in){
		if ($char eq "1" and $tmp eq "+"){
			$sentido = "+-";
		}
		elsif($char eq "1" and $tmp eq "-"){
			$sentido = "-+";
		}
		elsif($char eq "0" and $bit_pre eq "0"  and $tmp eq "+"){
			$sentido = "--";
		}
		elsif($char eq "0" and $bit_pre eq "0"  and $tmp eq "-"){
			$sentido = "++";
		}
		elsif($char eq "0" and $bit_pre eq "1"  and $tmp eq "-"){
			$sentido = "--";
		}
		elsif($char eq "0" and $bit_pre eq "1"  and $tmp eq "+"){
			$sentido = "++";
		}

		$bit_pre = $char;

		# Se guarda el sentido en el arreglo @salida
		push (@salida, $sentido);

		# Para determinar los cambios de polaridad (T o NT) se guarda el sentido de esta iteracion en $tmp
		$tmp = substr($sentido,1,1);
	}


	print "\nCodificacion MFM:\n";
	print_arr(@salida);

}


sub codificacion_RLL{

	#Metodo de codificacion: RLL
	# Data			 # Encoded
	# 1 0		      N T N N
	# 1 1  		    T N N N
	# 0 0 0			  N N N T N N
	# 0 1 0			  T N N T N N
	# 0 1 1			  N N T N N N
	# 0 0 1 0		  N N T N N T N N
	# 0 0 1 1		  N N N N T N N N


	$tmp = "+";
	@salida=();
	while(){
		if($bin_data_in eq "00" or $bin_data_in eq "1" or $bin_data_in eq "01" or $bin_data_in eq "001")	{	$bin_data_in.="0";}
		if($bin_data_in eq "0")										    	{ $bin_data_in.="00";}
		$pattern = substr($bin_data_in,0,2);
		if($pattern eq ""){last;} # Fin de cadena

		if($pattern eq "10" and $tmp eq "+"){
			$sentido = "+---";
			$bin_data_in = substr($bin_data_in,2,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}

		if($pattern eq "10" and $tmp eq "-"){
			$sentido = "-+++";
			$bin_data_in = substr($bin_data_in,2,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}



		if($pattern eq "11" and $tmp eq "+"){
			$sentido = "----";
			$bin_data_in = substr($bin_data_in,2,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}
		if($pattern eq "11" and $tmp eq "-"){
			$sentido = "++++";
			$bin_data_in = substr($bin_data_in,2,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}


		$pattern = substr($bin_data_in,0,3);
		if($pattern eq ""){last;} # Fin de cadena

		if($pattern eq "000" and $tmp eq "+"){
			$sentido = "+++---";
			$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}

		if($pattern eq "000" and $tmp eq "-"){
			$sentido = "---+++";
			$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}

		if($pattern eq "010" and $tmp eq "+"){
			$sentido = "---+++";
			$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}

		if($pattern eq "010" and $tmp eq "-"){
			$sentido = "+++---";
			$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}

		if($pattern eq "011" and $tmp eq "+"){
			$sentido = "++----";
			$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}

		if($pattern eq "011" and $tmp eq "-"){
			$sentido = "--++++";
			$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}

		$pattern = substr($bin_data_in,0,4);
		if($pattern eq ""){last;} # Fin de cadena

		if($pattern eq "0010" and $tmp eq "+"){
			$sentido = "++---+++";
			$bin_data_in = substr($bin_data_in,4,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}

		if($pattern eq "0010" and $tmp eq "-"){
			$sentido = "--+++---";
			$bin_data_in = substr($bin_data_in,4,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}
		if($pattern eq "0011" and $tmp eq "+"){
			$sentido = "++++----";
			$bin_data_in = substr($bin_data_in,4,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}

		if($pattern eq "0011" and $tmp eq "-"){
			$sentido = "----++++";
			$bin_data_in = substr($bin_data_in,4,length($bin_data_in));
			push (@salida, $sentido);
			$tmp = substr($sentido,-1,1);
			next;
		}



	}


	print "\nCodificacion RLL:\n";
	print_arr(@salida);


}
