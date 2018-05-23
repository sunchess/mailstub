<template lang="pug">
  #projects
    h1 Projects
    <md-button to="/projects/new">New Project</md-button>

    .div(v-if="projects.length")
      <md-table :value="projects" md-sort="name" md-sort-order="asc">
        <md-table-row slot="md-table-row" slot-scope="{ item }">
          <md-table-cell md-label="Name" md-sort-by="name">
            | {{ item.name }}
          </md-table-cell>
          <md-table-cell md-label="Actions">
            <md-button :to="{name: 'show_project', params:{project_id: item.id}}" class="md-icon-button md-primary">
                <md-icon>menu</md-icon>
            </md-button>
          </md-table-cell>
        </md-table-row>
      </md-table>

</template>

<script>
export default {
  name: 'projects',
  data: () => ({
    errors: null
  }),


  computed: {
    projects(){
      return this.$store.getters.currentProjects
    },

  }
}
</script>

<style lang="scss">
</style>
