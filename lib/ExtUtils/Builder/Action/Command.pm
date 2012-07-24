package ExtUtils::Builder::Action::Command;

use Moo;

with 'ExtUtils::Builder::Role::Action';

use IPC::System::Simple qw/systemx capturex/;

has program => (
	is       => 'ro',
	required => 1,
);

has arguments => (
	is       => 'ro',
	required => 1,
);

has env => (
	is       => 'ro',
	required => 1,
);

has logger => (
	is      => 'ro',
	default => sub { \*STDOUT },
);

sub listify {
	my $self = shift;
	return ($self->program, @{ $self->arguments });
}

sub execute {
	my ($self, %opts) = @_;
	my @command = $self->listify;
 	print { $opts{logger} || $self->logger } join(' ', map { s/(['#])/\\$1/g ? "'$_'" : $_ } @command), "\n" if not $opts{quiet};
	if (not $opts{dry_run}) {
		my $env = $self->env;
		local @ENV{keys %{$env}} = values %{$env};
		if ($opts{verbose}) {
			systemx(@command);
		}
		else {
			capturex(@command);
		}
	}
	return;
}

1;
