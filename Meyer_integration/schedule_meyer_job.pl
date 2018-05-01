#!/usr/bin/perl
# This is a script that utilizes the Alma Jobs API to run the "Send Requests to Remote Storage"
# job via cron. More info: 
# https://developers.exlibrisgroup.com/alma/apis/conf/POST/gwPcGly021p29HpB7XTI4If2K/a0Xsh6dG++dljuEGQ=/37088dc9-c685-4641-bc7f-60b5ca7cabed

use strict;
use XML::Simple;
use Data::Dumper;

my $working_dir = '/mnt/libraryfeed/ALMA/MEYER';
chdir ($working_dir);

# Be sure to create a file containing your api_key called 'api_key.txt' in this directory
my $api_key = `cat api_key.txt`;
chomp $api_key;
if (! $api_key) { die "Please provide an API key in a file called 'api_key.txt' in this directory"; }

my $curl = '/usr/bin/curl';
my $mailx = '/usr/bin/mailx';
#my $mailx = '/bin/mailx';
my $api_server = 'api-na.hosted.exlibrisgroup.com';

# find our job (Retrieve Jobs)
my $search = `curl -s 'https://$api_server/almaws/v1/conf/jobs?apikey=$api_key&profile_id=7562275960001401&category=FULFILLMENT'`;

my $job_ref = XMLin($search);
my $job = $job_ref->{job}{id};

# download the job object (Retrieve Job Details)
system ("curl -s -o meyer_job.xml 'https://$api_server/almaws/v1/conf/jobs/$job?apikey=$api_key'");

# run the job (Submit a manual or scheduled job)
my $response_xml = `$curl -H "Content-Type: application/xml" -X POST --data \@meyer_job.xml -s 'https://$api_server/almaws/v1/conf/jobs/S7696884050001401?apikey=$api_key&op=run'`;


my $ref = XMLin($response_xml);
#print Dumper($ref);


if ($ref->{errorsExist} eq "true") {
	open ERROR, ">>meyer_job_errors.txt" or die $!;
	print ERROR `date`;
	print ERROR $response_xml, "\n";
	close ERROR;
		
	open MAIL, "| $mailx -s 'Meyer job error!!!!!' g.mcclellan\@northeastern.edu";
	print MAIL XMLout($ref);
	close MAIL;

	exit;
}

open LOG, ">>meyer_job_log.txt" or die $!;
print LOG $ref->{additional_info}->{content}, "\n";
close LOG;

open MAIL, "| $mailx -s 'Meyer Job Ran' g.mcclellan\@northeastern.edu";
print MAIL XMLout($ref);
close MAIL;
