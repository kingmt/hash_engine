# encoding: utf-8
require 'hash_engine'

describe HashEngine do
  describe 'format' do
    # data,                       format_type,              output
    [['sample',                   'string',                 'sample'],
     ['  sample',                 'string',                 'sample'],
     ['sample  ',                 'string',                 'sample'],
     ['  sample  ',               'string',                 'sample'],
     [55,                         'string',                 '55'],
     [:sample,                    'string',                 'sample'],
     ['sample',                   'first',                  's'],
     ['ÑAlaman',                  'first',                  'Ñ'],
     [55,                         'first',                  '5'],
     ['sample',                   'alphanumeric',           'sample'],
     ['s_a+m=p%l-e',              'alphanumeric',           'sample'],
     [55,                         'alphanumeric',           '55'],
     ['sample',                   'no_whitespace',          'sample'],
     ['sam-ple',                  'no_whitespace',          'sam-ple'],
     ['s_a+m=p%le',               'no_whitespace',          'sample'],
     [55,                         'no_whitespace',          '55'],
     ['123sample',                'alpha',                  'sample'],
     ['s_a45m=p%l-e',             'alpha',                  'sample'],
     ['123sample',                'numeric',                '123'],
     ['682-59-7267',              'numeric',                '682597267'],
     ['ext 99',                   'numeric',                '99'],
     ['2000.99',                  'float',                  2000.99],
     ['sample',                   'integer',                0],
     ['123sample',                'integer',                123],
     [55,                         'integer',                55],
     [true,                       'integer',                1],
     [false,                      'integer',                0],
     [nil,                        'integer',                0],
     [Date.parse('2009-07-14'),   {'strftime'=>"%Y-%m-%d"}, '2009-07-14'],
     ['2009-07-14',               'date',                   Date.parse('2009-07-14')],
     ['true',                     'boolean',                true],
     ['TrUe',                     'boolean',                true],
     ['t',                        'boolean',                true],
     ['T',                        'boolean',                true],
     [1,                          'boolean',                true],
     ['yes',                      'boolean',                true],
     ['Y',                        'boolean',                true],
     [2,                          'boolean',                false],
     ['false',                    'boolean',                false],
     ['no',                       'boolean',                false],
     ['sample',                   'gibberish',              'sample'],
     ['sample',                   nil,                      'sample']
    ].each {|data, format_type, output|
      it "#{data.class} #{data.inspect} should be cast as #{format_type} #{output.inspect}" do
        HashEngine.action('format', format_type, data).should == output
      end
    }
  end
end
