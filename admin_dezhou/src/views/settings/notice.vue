<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">

      <el-form-item label="滚动公告">
        <el-input v-model="form.context"></el-input>
      </el-form-item>


      <el-form-item>
        <el-button type="primary" @click="onSubmit">立即设置</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { setnotice, getnotice } from '@/api/setting'
  export default {
    data() {
      return {
        listLoading: true,
        form: {
          context: ''
        }
      }
    },
    created() {
      this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
        getnotice().then(response => {
          console.log(response)
          this.form.context = response.data
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      handleModifyStatus() {
        this.$message({
          message: '设置成功',
          type: 'success'
        })
      },
      onSubmit() {
        this.listLoading = true
        setnotice(this.form).then(response => {
          this.handleModifyStatus()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      }
    }
  }
</script>
