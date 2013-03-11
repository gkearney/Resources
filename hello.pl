use Mojolicious::Lite;

use Cwd;
app->static->paths->[0] = getcwd;

any '/' => sub {
  shift->render_static('index.html');
};

app->start;