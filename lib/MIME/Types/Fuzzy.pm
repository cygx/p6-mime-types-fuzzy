my class FuzzyType {
    has $.type;
    has $.subtypes;
    has $.suffix;
    has $.x;
    has $!str;

    method TWEAK {
        $!str = "$!type/$.subtype";
        $!x = $_ eq 'x' || .starts-with('x-')
            given $!subtypes.head;
    }

    method Str { $!str }

    method subtype {
        $!suffix ?? "$_+$!suffix" !! $_
            given $!subtypes.join('.');
    }

    method guess-file-extension {
        $!x && $!subtypes == 1 ?? .substr(2) !! $_
            given $!subtypes.tail;
    }

    method TOP($/) {
        make self.new(
            type => $<type>.lc,
            subtypes => $<subtype>>>.lc.List,
            suffix => $<suffix> ?? $<suffix>.lc !! Nil
        );
    }
}

my class GuessFileExtension {
    method TOP($/) { make $<subtype>.tail<name>.lc }
}

class MIME::Types::Fuzzy {
    grammar Grammar {
        token name { [<.alnum>+]+ % '-' }
        token ex { 'x-' }
        token TOP {
            <type=.name> '/' $<subtype>=(<ex>? <name>)
                         ['.' $<subtype>=(<name>)]* ['+' <suffix=.name>]?
        }
    }

    method ACCEPTS($value) {
        so Grammar.parse($value);
    }

    method guess-file-extension($type) {
        Grammar.parse($type, actions => GuessFileExtension).?made;
    }

    method parse($type) {
        Grammar.parse($type, actions => FuzzyType).?made;
    }
}
