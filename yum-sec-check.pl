#!/usr/bin/perl

#### script that looks for security updates on yum based systems like CentOS
###
### http://code.google.com/p/yum-security-check/
### v 0.3.3
### last chage: 2013.08.14
###
####

use warnings;
use strict;
use Term::ANSIColor qw(:constants);

#### CONFIGURE HERE #########
### do you need email alerts?
my $send_mail = 1;
### enter emails to send reports to
my @mails_to = qw(
kursad.cokyaman@atos.net
);
#############################
my $gonderen = qw(
"LNX_Security_Update<lnx-sec-update@atos.net.tr>"
);

$| = 1;
my $date = scalar localtime();
my $ip = `/sbin/ip r get 8.8.8.8 | sed "s/.*src //"| head -n 1 | tr '\\n' ' ' && hostname`;
chomp $ip;
print<<EOF;

============================================
yum security check perl script
version 0.3.3
http://code.google.com/p/yum-security-check/
started: $date
server:  $ip
============================================

EOF

my $yum = `which yum`;
chomp $yum;
unless (-e $yum) {
    print BOLD, RED, "yum binary not found, make sure it's in your path or that you are on the correct OS (CentOS, RedHat etc)\n", RESET;
    exit;
}
my $yum_changelog = `rpm -qi yum-plugin-changelog yum-changelog| grep Name| wc -l`;
chomp $yum_changelog;
unless ($yum_changelog) {
    print BOLD, RED, "yum plugin 'yum-changelog' does not seem ot be installed, try running:\n", RESET;
    print BOLD, GREEN, "yum install -y yum-changelog\n", RESET;
    print BOLD, GREEN, "yum install -y yum-plugin-changelog\n", RESET;
    print BOLD, RED, "and then rerun this script.\n", RESET;
    exit;
}


print "Getting list of all packages";
my @packages = `/usr/bin/yum check-update 2>/dev/null | grep -e "x86" -e "i686" -e "i386" -e "noarch" | awk '{print \$1}'`;
print " "x35;
print BOLD, "[ ";
print GREEN, "DONE ", RESET;
print BOLD, "]\n", RESET;
chomp foreach @packages;

my $cnt = 0;
my $upcmd = '/usr/bin/yum --changelog update ';
my $update_needed = 0;

my $packages_num = $#packages + 1;
my $security_info = "You need to update this server,\ntotal of $packages_num packages are set for update - the following have security issues:\n";

my $cve = '';
my $length = '';
foreach (@packages) {
	print     "Checking package $_ (", ++$cnt, "/".($#packages+1).")";
	$length = length("Checking package $_ $cnt ".($#packages+1).")");
	my $str = `yes n | /usr/bin/yum --changelog update $_ 2>/dev/null`;
	foreach (split(/\n/, $str)) {
        	if (/(CVE-\d+-\d+)/) {
			$cve .= " ** ";
	                $cve .= $1;
        	        $cve .= " http://cve.mitre.org/cgi-bin/cvename.cgi?name=$1 \n";
        	}
	}
	
	if ($cve) {
		my $space = 60-$length;
		print " "x$space;
		print BOLD, "[ ";
		print RED, BOLD, "SECURITY UPDATE NEEDED", RESET;
		print " ]\n", RESET;
		print "$cve";
		$security_info .= "\n=========$_==============\n'$cve'\n";
		$upcmd .= "$_ ";
		$update_needed = 1;
		$cve = '';
	} else {
		my $space = 60-$length;
		print " "x$space;
		print BOLD, "[ ", RESET;
		print GREEN, BOLD, "pkg OK", RESET;
		print BOLD, " ]\n", RESET;
	}
}

$security_info .= "\n\nYou need to run:\n$upcmd\n";

if ($update_needed) {
	open FILE, ">/tmp/sec_updates_info";
	print FILE $security_info;
	close FILE;
	print "------\n\nYou need to update this server - run:\n $upcmd\n";
	if ($send_mail) {
		foreach (@mails_to) {
			`/scr/gonder $gonderen $_ "$ip needs update" /tmp/sec_updates_info`;
		}
	}
}

else {
	print "------\n\nNo securiity updates needed.\n";
}
