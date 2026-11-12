# frozen_string_literal: true

name 'windows_print'
default_source :supermarket

run_list 'test::default'
cookbook 'windows_print', path: '.'
cookbook 'test', path: './test/cookbooks/test'

Dir.glob('test/cookbooks/test/recipes/*.rb').each do |path|
  recipe = File.basename(path, '.rb')
  named_run_list recipe.to_sym, "test::#{recipe}"
end
