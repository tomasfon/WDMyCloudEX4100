#!/usr/bin/perl

# Autor: Tomás Fonseca
# Sitio web: https://www.nsoluciones.com/
# Fecha: Enero 2024
#
# ver 2.0
# si el nas devuelve en Terabytes lo convierte a Gigabytes


use strict;
use warnings;
use Net::SNMP;
use POSIX qw(strftime);

# Obtener parámetros de la línea de comandos
my ($hostname, $community, $warning_threshold, $critical_threshold) = @ARGV;

# Validar que se proporcionen todos los parámetros
unless (defined $hostname && defined $community && defined $warning_threshold && defined $critical_threshold) {
    die "Uso: $0 <hostname> <community> <warning_threshold> <critical_threshold>\n";
}

# OIDs específicos para tu NAS
my $oid_system_name = '1.3.6.1.2.1.1.5.0';  # Nombre del sistema
my $oid_free_space = '1.3.6.1.4.1.5127.1.1.1.6.1.9.1.6.1';  # Espacio libre en la unidad de almacenamiento

# Realizar la consulta SNMP
my ($session, $error) = Net::SNMP->session(
    -hostname  => $hostname,
    -community => $community,
    -version   => 2,  # SNMP versión 2c
);

die "Error al abrir la sesión SNMP: $error" unless $session;

# Obtener el nombre del sistema
my $result_system_name = $session->get_request(-varbindlist => [$oid_system_name]);

unless ($result_system_name) {
    printf "Error al obtener el nombre del sistema (%s): %s\n", $oid_system_name, $session->error();
    $session->close();
    exit 1;
}

my $system_name = $result_system_name->{$oid_system_name};
print "Nombre del sistema: $system_name\n";

# Obtener el espacio libre
my $result_free_space = $session->get_request(-varbindlist => [$oid_free_space]);

unless ($result_free_space) {
    printf "Error al obtener el espacio libre (%s): %s\n", $oid_free_space, $session->error();
    $session->close();
    exit 1;
}

# Obtener el espacio libre en gigabytes
my $free_space_gb = parse_space_value($result_free_space->{$oid_free_space});

# Verificar umbrales y emitir estado correspondiente
if ($free_space_gb <= $critical_threshold) {
    print "CRÍTICO: Espacio libre por debajo del umbral crítico ($critical_threshold GB). Espacio libre: $free_space_gb GB\n";
    $session->close();
    exit 2;  # Código de salida para estado crítico
} elsif ($free_space_gb <= $warning_threshold) {
    print "ADVERTENCIA: Espacio libre por debajo del umbral de advertencia ($warning_threshold GB). Espacio libre: $free_space_gb GB\n";
    $session->close();
    exit 1;  # Código de salida para estado de advertencia
} else {
    print "OK: Espacio libre dentro de los límites aceptables. Espacio libre: $free_space_gb GB\n";
    $session->close();
    exit 0;  # Código de salida para estado OK
}

# Subrutina para parsear el valor del espacio en gigabytes
sub parse_space_value {
    my ($value) = @_;

    # Extraer el valor numérico y la unidad
    if ($value =~ /^([\d.]+)([KMG])?$/) {
        my $num = $1;
        my $unit = $2 || 'B';

        # Convertir a gigabytes si es necesario
        if ($unit eq 'K') {
            return sprintf "%.2f", $num / 1024 / 1024;
        } elsif ($unit eq 'M') {
            return sprintf "%.2f", $num / 1024;
        } elsif ($unit eq 'G') {
            return $num;
        } elsif ($unit eq 'T') {
            return $num * 1024;
        }
    } elsif ($value =~ /^([\d.]+)T$/) {
        return $1 * 1024;  # Convertir terabytes a gigabytes
    }

    return 0;  # Valor predeterminado en caso de error
}
