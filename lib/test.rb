require "../config/environment" unless defined?(::Rails.root)

pparams = {}
pparams['a'] = 'aaa'
pparams['b'] = 'bbb'

parameters = pparams.clone

parameters.delete('a')

p pparams
p parameters
