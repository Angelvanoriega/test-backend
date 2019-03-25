import compose from 'koa-compose';

import user from './user';
import login from './login';
import sync from './sync';

export default () => compose([
  login(),
  user(),
  sync()
]);
