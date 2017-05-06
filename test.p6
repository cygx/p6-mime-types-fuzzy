use lib 'lib';
use MIME::Types::Fuzzy;

for 'types.list'.IO.lines {
    next if /^['#'|$]/;
    .say unless $_ ~~ MIME::Types::Fuzzy;
}
