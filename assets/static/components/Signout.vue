<template lang="pug">
  #signout
    .spinner
      <md-progress-spinner md-mode="indeterminate"></md-progress-spinner>
    .title
      <md-content>Signing out...</md-content>

</template>

<script>
export default {
  name: 'signout',
  data: () => ({
    errors: null
  }),

  created(){
    setTimeout(()=>{
      if(this.$store.getters.currentUser){
        this.$store.dispatch('LOGOUT')
      }
      this.$router.push({name: 'home'})
    }, 1500)

  }
}

</script>

<style lang="scss">
#signout{
  .spinner{
    width: 87px;
    margin: auto;
    div{
      margin-left: 11px;
    }
  }
  .title{
    font-weight: bold;
    width: 87px;
    margin: auto;
  }
}
</style>
