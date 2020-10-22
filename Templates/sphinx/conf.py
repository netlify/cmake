needs_sphinx = '3.2.1'
exclude_patterns = ['_build']

primary_domain = 'cpp'
html_static_path = ['custom.css']

html_css_files = [
    'https://cdn.jsdelivr.net/npm/firacode@5/distr/fira_code.css',
    'https://rsms.me/inter/inter.css',
]

dark = '#0E1E25'
green = '#00AD9F'
grey = '#2D3B41'
white = '#FFFFFF'
light_green = '#00C7B7'
blue = '#0183BF'

html_theme_options = dict(
    sidebar_width='200px',
    page_width='1200px',
    codecov_button=True,
    github_banner=True,
    github_button=True,
    badge_branch='main',

    body_text=dark,
    gray_1=grey,

    sidebar_link_underscore=light_green,
    sidebar_text=dark,

    link=green,
    link_hover=light_green,

    code_font_family="'Fira Code VF', 'Fira Code', monospace",
    font_family="'Inter var', 'Inter', sans-serif",
)

html_sidebars = {
    '**': [
        'about.html',
        'navigation.html',
        'relations.html',
        'searchbox.html',
        'donate.html',
    ]
}

autosectionlabel_prefix_document = True
todo_include_todos = True

extensions = [
    'sphinx.ext.autosectionlabel',
    'sphinx.ext.intersphinx',
    'sphinx.ext.extlinks',
    'sphinx.ext.graphviz',
    'sphinx.ext.todo',
]

def assign_github_properties(app, config):
    user = config.github.get('user')
    repo = config.github.get('repo')

    if not user and not repo: return
    links = dict(
        issue=(f'https://github.com/{user}/{repo}/issues/%s', 'GH-'),
        pr=(f'https://github.com/{user}/{repo}/pulls/%s', 'GH-'))

    config.html_theme_options.update(dict(github_user=user, github_repo=repo))
    config.extlinks.update(links)

def setup(app):
    from docutils.parsers.rst.roles import code_role
    from functools import partial
    cmake_role = partial(code_role, options=dict(language='cmake', classes=['highlight']))
    cxx_role = partial(code_role, options=dict(language='cpp', classes=['highlight']))

    app.connect('config-inited', assign_github_properties)

    app.add_config_value('github', dict(repo='', user=''), 'env')
    app.add_role('cmake', cmake_role)
    app.add_role('cxx', cxx_role)
