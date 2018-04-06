<template lang="pug">
  #main
    .md-layout
      .md-layout-item
        .logo
          <router-link style="color: #505050; text-decoration: none;" to="/">
            h1
              md-icon.md-size-2x call_merge
              | Mailstub
          </router-link>
      .md-layout-item.pull-right
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
  .pull-right{
    text-align: right;
  }
}
</style>
