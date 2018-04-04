<template lang="pug">
  #main
    .md-layout
      .md-layout-item
        .logo
          <router-link to="/">
            h1 Mailstub
          </router-link>
      .md-layout-item
        <md-button class="md-raised md-primary" to="/login" exact>Login</md-button>
        <md-button to="/signup">Sign up</md-button>
    #main-content
      router-view

</template>

<script>
export default {
  name: 'app'
}
</script>

<style lang="scss">
@import '../css/app.scss';

#main {
  width: 80%;
  margin: 0 auto;
  padding-top: 20px;
}
.router-link-active{
  a{
    color: #ccc;
  }
}
</style>
