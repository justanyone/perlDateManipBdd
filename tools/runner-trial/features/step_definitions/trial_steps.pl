use strict;
use warnings;
use utf8;
use Test::More;
use Test::BDD::Cucumber::StepFile;
Given 'a fresh trial record', sub {
    ok(!exists S->{text}, 'scenario state starts empty');
};
When qr/^I remember "(.*)"$/, sub {
    S->{text}=C->matches->[0];
};
Then qr/^the remembered text is "(.*)"$/, sub {
    is(S->{text},C->matches->[0],'literal text matches');
};
When 'I receive these records:', sub { S->{records}=C->data; };
Then 'the records contain the two expected ordered entries', sub {
    is_deeply(S->{records},[
        {label=>'first',value=>'février'},
        {label=>'second',value=>'EST|-0500'},
    ],'data table preserves values and order');
};
When 'I receive this text:', sub { S->{text}=C->data; };
Then 'the multiline text contains the two expected lines and a final newline', sub {
    is(S->{text},"first line\ndeuxième ligne\n",'docstring preserves lines');
};
