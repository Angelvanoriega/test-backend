import Router from 'koa-router';

import { createUser, updateUser, userExists, destroyUser, getUsers } from '../controllers/userController';
import { validateFields } from './validators';

const router = new Router();


async function create(ctx) {
  const userName = ctx.request.body.name;
  const userEmail = ctx.request.body.email;
  const userBirthday = ctx.request.body.birthday;

  try {
    validateFields(userName, userEmail, userBirthday);
    await createUser(ctx, userName, userEmail, userBirthday);

    ctx.status = 201;
    ctx.body = { message: 'Created' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { message: error.message };
  }
}

async function update(ctx) {
  const userId = ctx.params.id;
  const userName = ctx.request.body.name;
  const userEmail = ctx.request.body.email;
  const userBirthday = ctx.request.body.birthday;

  try {
    validateFields(userName, userEmail, userBirthday);
    await userExists(ctx, userId);
    await updateUser(ctx, userId, userName, userEmail, userBirthday);

    ctx.status = 200;
    ctx.body = { message: 'Updated' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { message: error.message };
  }
}

async function destroy(ctx) {
  const userId = ctx.params.id;

  try {
    await userExists(ctx, userId);
    await destroyUser(ctx, userId);

    ctx.status = 200;
    ctx.body = { message: 'Deleted' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { message: error.message };
  }
}

async function get(ctx) {
  try {
    const users = await getUsers(ctx);

    ctx.status = 200;
    ctx.body = { users };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { message: error.message };
  }
}


router.post('/register', create);
router.put('/api/users/:id', update);
router.del('/api/users/:id', destroy);
router.get('/users', get);

const routes = router.routes();
export default () => routes;
