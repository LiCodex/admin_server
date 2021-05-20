var merge = require('webpack-merge')
var prodEnv = require('./prod.env')

module.exports = merge(prodEnv, {
  NODE_ENV: '"development"',
  // BASE_API: '"https://easy-mock.com/mock/5950a2419adc231f356a6636/vue-admin"',
  BASE_API: '"http://18.224.149.182:19004"',
  BASE_API_GONGNENG: '"http://18.224.149.182:19015"',
  // LOGIN_URI: '"/user/login"'
  LOGIN_URI: '"/adminlogin"',
  // INFO_URI: '"/user/info"',
  INFO_URI: '"/admininfo"',
  // INFO_URI: '"/user/logout"',
  LOGOUT_URI: '"/adminlogout"',
  IMG_API: '"http://127.0.0.1:10001"',

})
