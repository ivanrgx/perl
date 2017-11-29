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




#Metodo de codificacion: MFM
# Data			# Encoded
# 1			  N T
# 0 precedido por 0	  T N
# 0 precedido por 1	  N N

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











	
sub print_arr{
	foreach my $el (@_){
		print "$el";
	}
	print"\n";
}