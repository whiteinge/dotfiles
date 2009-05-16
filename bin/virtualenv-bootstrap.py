"""A bootstrap script to create a virtualenv startup script with a custom
environment.

Usage example::

    python virtualenv-bootstrap.py > create_django_env.py
    python create_django_env.py --no-site-packages foobar

"""
import virtualenv, textwrap

output = virtualenv.create_bootstrap_script(textwrap.dedent("""
def after_install(options, home_dir):
    subprocess.call([join(home_dir, 'bin', 'easy_install'), 'pip'])

"""))
print output
