#!/usr/bin/perl -w
use strict;

# Proyecto final de dispositivos
# Programa que regresa el sentido magnético teórico (+ o -) que deberá guardarse en un disco magnético
# de una entrada específica en binario
# El sentido magnético dependerá de la cadena de entrada y método de codificación

# NOTA: Se tomará como sentido + el campo que precede a la parte del disco magnético donde se grabaría la información


# Variable de entrada
my $bin_data_in;
print ("Ingresar dato de entrada\n");
$bin_data_in = <STDIN>;
chomp($bin_data_in);


#Se checa que el dato sea valido

unless($bin_data_in=~ /^[01]+$/){ 
	die "Dato de entrada invalido, unicamente ingresar 0's y 1's\n\n";
}

# Método de codificación: Non-Return-to-Zero-Inverted (NRZI)
# simply encodes a 1 as a magnetic polarity transition, also known as a "flux reversal", and a zero as no transition.

my $tmp="+";
my $sentido;
my @salida;
my @bin_data_in = split(//,$bin_data_in);

foreach my $char (@bin_data_in){
	# Dependiendo de el bit de entrada, es que se determinará el sentido del campo magnético
        # que se guardará en el disco magnético;
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


# Imprime salida que se guardaria en el disco magnético

print "\nDato entrada: $bin_data_in\n";

print "Codificacion NRZI:\n";
print_arr(@salida);


#Metodo de codificacion: FM
# Data	# Encoded
# 0	  T N
# 1	  T T

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




#Metodo de codificacion: MFM		Suponemos que se encuentra un 0 en el disco antes de ingresar información
# Data			# Encoded
# 1			  N T
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




#Metodo de codificacion: RLL		
# Data			# Encoded
# 1 0			  N T N N
# 1 1			  T N N N
# 0 0 0			  N N N T N N
# 0 1 0			  T N N T N N
# 0 1 1			  N N T N N N
# 0 0 1 0		  N N T N N T N N
# 0 0 1 1		  N N N N T N N N


$tmp = "+";
$pattern;
@salida=();
while(){
	$pattern = substr($bin_data_in,0,2);
	if($pattern eq ""){last;} # Fin de cadena
	
	if($pattern eq "10" and $tmp eq "+"){
		$sentido = "+---";
		$bin_data_in = substr($bin_data_in,2,length($bin_data_in));
		push (@salida, $sentido);
		$tmp = substr($sentido,-1,1);
		next;
	}
	elif($pattern eq "10" and $tmp eq "-"){
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
	elif($pattern eq "11" and $tmp eq "-"){
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
		$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
		push (@salida, $sentido);
		$tmp = substr($sentido,-1,1);
		next;
	}

	if($pattern eq "0010" and $tmp eq "-"){
		$sentido = "--+++---";
		$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
		push (@salida, $sentido);
		$tmp = substr($sentido,-1,1);
		next;
	}
	if($pattern eq "0011" and $tmp eq "+"){
		$sentido = "++++-----";
		$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
		push (@salida, $sentido);
		$tmp = substr($sentido,-1,1);
		next;
	}

	if($pattern eq "0011" and $tmp eq "-"){
		$sentido = "----++++";
		$bin_data_in = substr($bin_data_in,3,length($bin_data_in));
		push (@salida, $sentido);
		$tmp = substr($sentido,-1,1);
		next;
	}


}





	
sub print_arr{
	foreach my $el (@_){
		print "$el";
	}
	print"\n";
}