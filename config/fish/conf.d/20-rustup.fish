if test -f "$CARGO_HOME/env.fish"
    source "$CARGO_HOME/env.fish"
else if test -d "$CARGO_HOME/bin"; and not contains -- "$CARGO_HOME/bin" $PATH
    set -gx PATH "$CARGO_HOME/bin" $PATH
end
