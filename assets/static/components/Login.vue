<template lang="pug">
  #login
    .form.md-card.md-layout-item.md-size-25.md-small-size-100
      <md-field md-clearable>
        <label>Email</label>
        <md-input v-model="email"></md-input>
      </md-field>

      <md-field>
        <label>Password</label>
        <md-input v-model="password" type="password"></md-input>
      </md-field>
</template>

<script>
export default {
  name: 'login'
}
</script>

<style lang="scss">
  #login{
    .form{
      width: 300px;
      margin: 0 auto;
      padding: 10px
    }
  }
</style>
