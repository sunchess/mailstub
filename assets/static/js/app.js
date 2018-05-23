// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import Vue from 'vue'
import VueResource from 'vue-resource'
import VueRouter from 'vue-router'
import VueMaterial from 'vue-material'
import underscore from 'vue-underscore';

import { store } from '../store/store'
//import 'vue-material/dist/vue-material.css'

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


// Import Vue components
import App from "../components/App"
import Home from "../components/Home"
import Login from "../components/Login"
import Signout from "../components/Signout"
import SignUp from "../components/SignUp"
import Projects from "../components/Projects"
import FormProject from "../components/FormProject"
import ShowProject from "../components/ShowProject"

Vue.config.productionTip = false

Vue.use(VueMaterial)
Vue.use(VueResource)
Vue.use(underscore)

Vue.use(VueRouter)
Vue.http.options.root = '/api';

console.log(store.getters.currentToken)
const router = new VueRouter({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home,
    },
    {
      path: '/login',
      name: 'login',
      component: Login,
    },
    {
      path: '/signout',
      name: 'signout',
      component: Signout,
    },
    {
      path: '/signup',
      name: 'signup',
      component: SignUp,
    },
    {
      path: '/projects',
      name: 'projects',
      component: Projects,
      meta: {auth: true}
    },
    {
      path: '/projects/new',
      name: 'new_project',
      component: FormProject,
      meta: {auth: true}
    },
    {
      path: '/projects/:project_id',
      name: 'show_project',
      component: ShowProject,
      meta: {auth: true}
    }
  ]
});

router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.auth) && !store.getters.currentUser) {
    next({ path: '/login', query: { redirect: to.fullPath }});
  } else {
    next();
  }
});


Vue.http.interceptors.push((request, next)  => {
  request.headers.set('Authorization', 'Bearer: ' + store.getters.currentToken);
  next((response) => {
    if(response.status == 401 ) {
      //store.dispatch('LOGOUT')
      //router.push({name: 'login'});
      console.log("401")
    }
  });
});

new Vue({
  el: '#app',
  store,
  router,
  template: '<App/>',
  components: { App }
});
