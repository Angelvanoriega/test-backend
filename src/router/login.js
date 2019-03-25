import Router from 'koa-router';
import jwt from 'jsonwebtoken';

import { getUserByEmailName } from '../controllers/userController';
import { validateLogin } from './validators';

const router = new Router();

async function login(ctx) {
  try {
    const userName = ctx.request.body.name;
    const userEmail = ctx.request.body.email;
    validateLogin(userName, userEmail);
    const user = await getUserByEmailName(ctx, userName, userEmail);
    const token = await jwt.sign({ user }, 'secretkey', { expiresIn: '300s' });
    ctx.status = 200;
    ctx.body = { key: token };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { message: error.message };
  }
}

router.post('/login', login);

const routes = router.routes();
export default () => routes;
