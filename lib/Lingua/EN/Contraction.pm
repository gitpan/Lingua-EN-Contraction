package Lingua::EN::Contraction;

use Data::Dumper;
require Exporter;

@ISA = qw( Exporter );

@EXPORT_OK = qw(

  contraction
  contract_n_t
  contract_other

);

use warnings;
use strict;
use diagnostics;


use vars qw(
  $VERSION
);


$VERSION = '0.1';


our $modal_re =   re_ify_list(qw(might must do does did should could can));
our $pronoun_re = re_ify_list(qw(I you we he she it they));
our $that_re    = re_ify_list(qw(there this that));
our $other_re =   re_ify_list(qw(who what when where why how));

our $verbs_re =   re_ify_list(qw(are is am was were will would have has had));

sub contraction {

	my $phrase = shift;

	# contract "not" before contracting other stuff...
	
	$phrase = contract_n_t($phrase);
	$phrase = contract_other($phrase);

	return $phrase;
}


sub contract_n_t {

		# MODAL-NOT -> MODAL-N_T (that is, "were not" becomes "weren't")
		# MODAL-PRONOUN-NOT -> MODAL-N_T-PRONOUN (that is, "were we not" becomes "weren't we")


	my $phrase = shift;

	my $new_phrase = $phrase;
	
	while ($phrase =~ /(\b($modal_re|$verbs_re) ($pronoun_re )?(not)\b)/ig) {
		my $orig_phrase = $1;
		my $_phrase = $1;
		
	
		if ( $_phrase =~ /\b($modal_re|$verbs_re) (not)\b/i  ) {
			my $m = $1;
			my $n = $2;
			if (my $m2 = N_T($m, $n)) {
				$_phrase =~ s/\b$m not\b/$m2/i;
			}
		}
		if ($_phrase =~ /($modal_re|$verbs_re) ($pronoun_re) (not)\b/i ) {
			my $p = $2; my $m = $1;
			my $n = $3;
			if (my $m2 = N_T($m, $n)) {
				$_phrase =~ s/\b$m $p not\b/$m2 $p/i;
			}
		}
		next if $orig_phrase eq $_phrase;
		$phrase =~ s/$orig_phrase/$_phrase/;
	}
	return $phrase;

}

sub contract_other {
	my $phrase = shift;

	my $phrase_start_pos = 0;
	while ($phrase =~ /\b(cannot|let us)/ig) {
		$phrase =~ s/\b(can)no(t)/$1'$2/i;
		$phrase =~ s/\b(let) u(s)/$1'$2/i;
	}

	while ($phrase =~ /(\b([\w']*(?: not)?) ?($pronoun_re|$other_re|$modal_re|$that_re) ($verbs_re)\b)/ig) {
		#print "1 -> $1\n\t, 2-> $2, 3->$3, 4->$4\n";
		my $orig_phrase = $1;
		my $_phrase = $1;
		my $w1 = $2;

		# don't form contractions following modal verbs:
		# nobody ever says "could I've been walking?", they say "could I have been walking?".
		next if $w1 =~ /$modal_re/;

		$_phrase =~ s/\b(I) a(m)\b/$1'$2/i;

		$_phrase =~ s/\b($pronoun_re|$other_re|$that_re) ha(d)\b/$1'$2/i;
		$_phrase =~ s/\b($pronoun_re|$other_re|$that_re) woul(d)\b/$1'$2/i;

		$_phrase =~ s/\b($pronoun_re|$other_re|$that_re) wi(ll)\b/$1'$2/i;

		$_phrase =~ s/\b($pronoun_re|$other_re) a(re)\b/$1'$2/i;

		$_phrase =~ s/\b($pronoun_re|$other_re|$that_re) i(s)\b/$1'$2/i;
		$_phrase =~ s/\b($pronoun_re|$other_re|$that_re) ha(s)\b/$1'$2/i;

		$_phrase =~ s/\b($pronoun_re|$other_re|$modal_re|$that_re) ha(ve)\b/$1'$2/i;

		next if $_phrase eq $orig_phrase;
		$phrase =~ s/$orig_phrase/$_phrase/;
	}
	return $phrase;
}

sub N_T {
    use locale;

    #add contracted negation to modal verbs:
    my $modal       = shift;
    my $not 	    = shift;
    die "unexpected value for 'not'\n" unless $not =~ /not/i;

	# preserve orginal case for "NOT->N'T" and "not->n't"
	# but change case for "Not" -> "n't"

    my $n_t = 	$not =~ /N[oO]T/ ? "N'T":
		$not =~ /n[oO]T/ ? "n'T":
		 		   "n't";
    
    if (lc($modal) eq 'am') {return "$modal $not"; }

	# cases where simply adding "n't" doesn't work:
	# will->won't, can->can't, shall->shan't
	# trying to preserve original case...

  	   $modal =~ s/((?i)w)I(?i)LL/$1O/;
  	   $modal =~ s/((?i)w)i(?i)ll/$1o/;
 	   $modal =~ s/((?i)c)A(?i)N/$1A/;
 	   $modal =~ s/((?i)c)a(?i)n/$1a/;
 	   $modal =~ s/(SHA)LL/$1/i;

    my $answer = $modal . $n_t;

    return    $modal eq lc($modal) ? lc($answer):
	      $modal eq uc($modal) ? uc($answer):
	      $modal eq ucfirst($modal) ? ucfirst($answer):
				$answer;

}

sub re_ify_list {
	my $re = '\b(?:' . join("|", @_) . ')';
	$re = qr/$re/i;
}

1;

=head1 NAME

Lingua::EN::Contraction - Add apostrophes all over the place... 

=head1 SYNOPSIS

	use Lingua::EN::Contraction qw(contraction);

	$sentance = "No, I am not going to explain it. If you cannot figure it out, you did not want to know anyway...  :-)";
	 
	print contraction($sentance) ;


=head1 DESCRIPTION

A very simple, humble little module that adds apostrophes to your sentances for you.  There aren't any options, so if you 
don't like the way it contracts things then you'll have to change the code a bit.  It'll preserve capitalization, so if 
you feed it things like "DO NOT PANIC", you'll get "DON'T PANIC" out the other end.  

=head1 BUGS

=head1 TODO

=head1 AUTHOR

Russ Graham, russgraham@gmail.com

=cut

