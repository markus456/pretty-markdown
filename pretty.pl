#!/usr/bin/perl
use feature 'unicode_strings';
use open ":std", ":encoding(UTF-8)";
use Term::ANSIColor qw(:constants color colored);

$code_block_color = FAINT GREEN;
$code_color = GREEN;
$header_color = BOLD WHITE;

$in_code = 0;

while (<STDIN>){
    if (/^```[a-z]*/) {
        if ($in_code) {
            $in_code = 0;
            print RESET;
            print '';
        } else {
            $in_code = 1;
            print '';
            print $code_block_color;
        }
    } elsif ($in_code) {
        print $code_block_color . $_;
    } else {
        $in_header = 0;
        $reset_color = RESET;

        if (/^ *[#]+/) {
            $in_header = 1;
            $reset_color = $header_color;
            print $reset_color;
        }

        # Convert inline code first
        s/[`]([^`]+)[`]/$code_color.$1.$reset_color/eg;

        # Markdown links, only supported by some terminals
        s/\[(.*)\]\(http([^)]+)\)/\e]8;;http$2\e\\$1\e]8;;\e\\/g;
        s/\[(.*)\]\(([^)]+)\)/ITALIC.$1.$reset_color.' ('.FAINT.WHITE.$2.$reset_color.')'/ge;

        # Bold and italic
        s/([*_]{3})(.*?)\g1/BOLD.ITALIC.$2.$reset_color /eg;

        # Bold
        s/([*_]{2})(.*?)\g1/BOLD.$2.$reset_color /eg;

        # Italic
        s/([*_]{1})(.*?)\g1/ITALIC.$2.$reset_color /eg;

        # List, convert into Unicode characters
        s/^( *)[-*]/$1\x{2022}/;

        print $_;

        if ($in_header) {
            print RESET;
        }
    }
}
