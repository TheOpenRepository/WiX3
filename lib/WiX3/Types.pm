package                                # Hide from PAUSE.
  WiX3::Types;

use 5.008001;
use MooseX::Types -declare => [ qw(
	  Host Tracelevel IsTag _YesNoType YesNoType ComponentGuidType PositiveInt
	  NonNegativeInt TraceConfig TraceObject EnumRemoveFolderOn
	  ) ];
use Regexp::Common 2.105;
use MooseX::Types::Moose qw( Str Int Bool HashRef );
use Readonly 1.03 qw( Readonly );

our $VERSION = '0.007';
$VERSION = eval $VERSION; ## no critic(ProhibitStringyEval)

# Assemble the GUID regex from pieces.
Readonly my $HEX => '0-9A-F';
Readonly my $GUID_MIDDLE_PART => "[$HEX]{4}";
Readonly my $GUID_MIDDLE => "[-] $GUID_MIDDLE_PART [-] $GUID_MIDDLE_PART [-] $GUID_MIDDLE_PART [-]";
Readonly my $GUID_BEGINNING => "[$HEX]{8}";
Readonly my $GUID_END => "[$HEX]{12}";
Readonly my $GUID_OPEN => '\A [{(]?';
Readonly my $GUID_CLOSE => '[})]? \z';
Readonly my $GUID_QR => qr{$GUID_OPEN $GUID_BEGINNING $GUID_MIDDLE $GUID_END $GUID_CLOSE}msx;

subtype Host, as Str, where {
	$_ =~ /\A $RE{net}{IPv4} \z/msx
	  or $_ =~ /\A $RE{net}{domain}{-nospace} \z/msx;
}, message {
	"$_ is not a valid hostname";
};

enum EnumRemoveFolderOn, qw( install uninstall both );

subtype IsTag, as role_type 'WiX3::XML::Role::Tag';

subtype TraceConfig, as class_type 'WiX3::Trace::Config';

subtype TraceObject, as class_type 'WiX3::Trace::Object';

subtype Tracelevel,
  as Int,
  where { ( $_ >= 0 ) && ( $_ <= 5 ) },
  message {"The tracelevel you provided, $_, was not valid."};

subtype _YesNoType,
  as Str,
  where { ( lc $_ eq 'yes' ) or ( lc $_ eq 'no' ); },
  message {"$_ is not yes or no"};

subtype YesNoType,
  as _YesNoType,
  where { ( $_ eq 'yes' ) or ( $_ eq 'no' ); },
  message {"$_ is not yes or no"};

coerce YesNoType, from _YesNoType, via { lc $_ };

coerce YesNoType, from Bool | Int, via { $_ ? 'yes' : 'no' };

subtype ComponentGuidType, as Str, where {
	$_ =~ $GUID_QR;
}, message {
	"$_ is not a GUID";
};

subtype PositiveInt,
  as Int,
  where { $_ > 0 },
  message {'Number is not larger than 0'};

subtype NonNegativeInt,
  as Int,
  where { $_ >= 0 },
  message {'Number is smaller than 0'};

# type coercion
coerce PositiveInt, from Int, via {1};

# type coercion
coerce NonNegativeInt, from Int, via {1};

1;                                     # Magic true value required at end of module
