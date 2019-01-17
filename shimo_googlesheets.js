const { sequelize, his } = require('./index')
const al = require('./index').al_readonly
const _ = require('lodash')
const moment = require('moment')
const shence = require('./shence')

// 筛选非钉钉企业用户
const dingtalkMemberUserIdsSql = `
  select user_id
  from dingtalk_members
  where user_id is not null
`

// 筛选非微信企业用户
const weworkMemberUserIdsSql = `
  select user_id
  from wework_member
  where user_id is not null
`

// 筛选非钉钉企业
const dingtalkCorpsTeamIdsSql = `
  select team_id
  from dingtalk_corps
  where team_id is not null
`

// 筛选非微信企业
const weworkCorpsTeamIdsSql = `
  select team_id
  from wework_corp
  where team_id is not null
`

// 主站用户数
// 包括主站企业版以及个人用户
exports.webUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where register_time <= '${to}'
    and ((ref != 'syc') or (ref is null))
    and (
      team_id not in (${dingtalkCorpsTeamIdsSql})
      and team_id not in (${weworkCorpsTeamIdsSql})
      or team_id is null
    )
  `))[0][0].count
}

// 钉钉用户数
exports.dingtalkUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from dingtalk_members
    where created_at <= '${to}'
  `))[0][0].count
}

// 注册用户总数
exports.registerCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where status in (0, 1)
    and ((ref != 'syc') or (ref is null))
    and ((register_time <= '${to}') or (register_time is null))
  `))[0][0].count
}

// 企业微信用户总数
exports.weworkUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from wework_member
    where created_at <= '${to}'
  `))[0][0].count
}

// 个人版用户总数
exports.personalUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where team_id is null
    and register_time <= '${to}'
  `))[0][0].count
}

// 企业版用户总数
exports.teamUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where team_id is not null
    and register_time <= '${to}'
  `))[0][0].count
}

// 付费企业用户数
exports.purchasedTeamUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where team_id is not null
    and register_time <= '${to}'
    and team_id in (
      select distinct target_id
      from orders
      where category = 2
      and is_paid = 1
    )
  `))[0][0].count
}

// 注册企业总数
exports.teamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from teams
    where createdAt <= '${to}'
  `))[0][0].count
}

// 主站企业总数
exports.webTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from teams
    where id not in (${dingtalkCorpsTeamIdsSql})
    and id not in (${weworkCorpsTeamIdsSql})
    and createdAt <= '${to}'
  `))[0][0].count
}

// 钉钉企业总数
exports.dingtalkTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from teams
    where id in (${dingtalkCorpsTeamIdsSql})
    and createdAt <= '${to}'
  `))[0][0].count
}

// 微信企业总数
exports.weworkTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from teams
    where id in (${weworkCorpsTeamIdsSql})
    and createdAt <= '${to}'
  `))[0][0].count
}

// 付费企业总数
exports.purchasedTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from orders
    where category = 2
    and created_at <= '${to}'
    and is_paid = 1
    and redeem_id is null
  `))[0][0].count
}

// 主站付费企业数
exports.webPurchasedTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from orders
    where category = 2
    and created_at <= '${to}'
    and is_paid = 1
    and redeem_id is null
    and target_id not in (${dingtalkCorpsTeamIdsSql})
    and target_id not in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 钉钉付费企业数
exports.dingtalkPurchasedTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from orders
    where category = 2
    and created_at <= '${to}'
    and is_paid = 1
    and redeem_id is null
    and target_id in (${dingtalkCorpsTeamIdsSql})
  `))[0][0].count
}

// 微信付费企业数
exports.weworkPurchasedTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from orders
    where category = 2
    and created_at <= '${to}'
    and is_paid = 1
    and redeem_id is null
    and target_id in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 激活用户总数
exports.activateCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where ((activate_time <= '${to}') or (activate_time is null))
    and status = 1
    and ((ref != 'syc') or (ref is null))
  `))[0][0].count
}

// 新增注册用户数
exports.newRegisterCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where register_time between '${since}' and '${to}'
  `))[0][0].count
}

// 主站新增用户数
exports.newWebUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where register_time between '${since}' and '${to}'
    and id not in (${dingtalkMemberUserIdsSql})
    and id not in (${weworkMemberUserIdsSql})
  `))[0][0].count
}

// 主站企业用户总数
exports.webTeamUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where team_id is not null
    and register_time <= '${to}'
    and team_id not in (${dingtalkCorpsTeamIdsSql})
    and team_id not in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 新增主站企业用户
exports.newWebTeamUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where team_id is not null
    and register_time between '${since}' and '${to}'
    and team_id not in (${dingtalkCorpsTeamIdsSql})
    and team_id not in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 钉钉新增用户数
exports.newDingtalkUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from dingtalk_members
    where created_at between '${since}' and '${to}'
  `))[0][0].count
}

// 微信新增用户数
exports.newWeworkUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from wework_member
    where created_at between '${since}' and '${to}'
  `))[0][0].count
}

// 新增基础版用户数
exports.newPersonalUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where register_time between '${since}' and '${to}'
    and id not in (
      select target_id
      from orders
      where is_paid = 1
      and category = 1
      and redeem_id is null
    )
    and team_id is null
  `))[0][0].count
}

// 新增高级版用户数
exports.newPremiumUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where register_time between '${since}' and '${to}'
    and id in (
      select target_id
      from orders
      where is_paid = 1
      and category = 1
      and redeem_id is null
    )
    and team_id is null
  `))[0][0].count
}

// 新增企业用户数
exports.newTeamUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where register_time between '${since}' and '${to}'
    and team_id is not null
  `))[0][0].count
}

// 新增有效企业用户数
exports.newValidTeamUsersCount = async (ids, since, to) => {
  return (await sequelize.query(`
    select count(u.id) count
    from users u, teams t
    where t.createdAt between '${since}' and '${to}'
    and u.team_id is not null
    and u.team_id = t.id
    and u.id in (${ids.join(',')})
  `))[0][0].count
}

// 新增付费企业用户数
exports.newPurchasedTeamsUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where register_time between '${since}' and '${to}'
    and team_id is not null
    and team_id in (
      select target_id
      from membership
      where category = 2
      and is_official = 1
    )
  `))[0][0].count
}

// 新增企业总数
exports.newTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from teams
    where createdAt between '${since}' and '${to}'
  `))[0][0].count
}

// 新增主站企业数
exports.newWebTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from teams
    where createdAt between '${since}' and '${to}'
    and id not in (${dingtalkCorpsTeamIdsSql})
    and id not in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 新增钉钉企业数
exports.newDingtalkTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from teams
    where createdAt between '${since}' and '${to}'
    and id in (${dingtalkCorpsTeamIdsSql})
  `))[0][0].count
}

// 新增微信企业数
exports.newWeworkTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from teams
    where createdAt between '${since}' and '${to}'
    and id in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 新增付费企业总数
exports.newPurchasedTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from orders
    where created_at between '${since}' and '${to}'
    and category = 2
    and is_paid = 1
  `))[0][0].count
}

// 新增主站付费企业数
exports.newWebPurchasedTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from orders
    where created_at between '${since}' and '${to}'
    and category = 2
    and is_paid = 1
    and target_id not in (${dingtalkCorpsTeamIdsSql})
    and target_id not in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 新增钉钉付费企业数
exports.newDingtalkPurchasedTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from orders
    where created_at between '${since}' and '${to}'
    and category = 2
    and is_paid = 1
    and target_id in (${dingtalkCorpsTeamIdsSql})
  `))[0][0].count
}

// 新增微信付费企业数
exports.newWeworkPurchasedTeamsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from orders
    where created_at between '${since}' and '${to}'
    and category = 2
    and is_paid = 1
    and target_id in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 个人版付费用户总数（累积）
exports.personalPermiumUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from orders
    where category = 1
    and is_paid = 1
    and created_at <= '${to}'
    and redeem_id is null
  `))[0][0].count
}

// 个人版付费用户数（有效）
exports.validPersonalPermiumUsersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(distinct target_id) count
    from membership
    where category = 1
    and expired_at > '${to}'
    and target_id in (
      select target_id
      from orders
      where category = 1
      and is_paid = 1
      and redeem_id is null
    )
  `))[0][0].count
}

// 文档总数
exports.filesCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from files
    where type in (0, -2)
    and created_at <= '${to}'
  `))[0][0].count
}

// 新增文档数
exports.newFilesCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from files f
    where f.created_at
    between '${since}' and '${to}'
    and f.type in (0, -2)
  `))[0][0].count
}

// 新增激活用户数
exports.newActivateCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where activate_time
    between '${since}' and '${to}'
  `))[0][0].count
}

// 文件夹总数
exports.foldersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from files f
    where f.created_at <= '${to}'
    and f.type = 1
  `))[0][0].count
}

// 新增文件夹数
exports.newFoldersCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from files f
    where f.created_at
    between '${since}' and '${to}'
    and f.type = 1
  `))[0][0].count
}

// 表格总数
exports.sheetsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from files f
    where f.created_at <= '${to}'
    and f.type in (-1, -3, -4)
  `))[0][0].count
}

// 新增表格数
exports.newSheetsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from files f
    where f.created_at
    between '${since}' and '${to}'
    and f.type in (-1, -3, -4)
  `))[0][0].count
}

// 活跃用户
exports.activeUserIds = async (since, to) => {
  return await shence.activeUserIds(since, to)
}

// 主站活跃用户数
exports.webActiveUsersCount = async (ids) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where id in (${ids.join(',')})
    and (
      team_id is null
      or (
        team_id not in (${dingtalkCorpsTeamIdsSql})
        and team_id not in (${weworkCorpsTeamIdsSql})
      )
    )
  `))[0][0].count
}

// 钉钉活跃用户数
exports.dingtalkActiveUsersCount = async (ids) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where id in (${ids.join(',')})
    and team_id in (${dingtalkCorpsTeamIdsSql})
  `))[0][0].count
}

// 微信活跃用户数
exports.weworkActiveUsersCount = async (ids) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where id in (${ids.join(',')})
    and team_id in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 个人版活跃用户数
exports.personalActiveUsersCount = async (ids) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where id in (${ids.join(',')})
    and team_id is null
  `))[0][0].count
}

// 企业版活跃用户数
exports.teamActiveUsersCount = async (ids) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where id in (${ids.join(',')})
    and team_id is not null
  `))[0][0].count
}

// 活跃企业数
exports.activeTeamsCount = async (ids) => {
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users
    where id in (${ids.join(',')})
  `))[0][0].count
}

// 主站活跃企业数
exports.webActiveTeamsCount = async (ids) => {
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users
    where id in (${ids.join(',')})
    and team_id not in (${dingtalkCorpsTeamIdsSql})
    and team_id not in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 钉钉活跃企业数
exports.dingtalkActiveTeamsCount = async (ids) => {
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users
    where id in (${ids.join(',')})
    and team_id in (${dingtalkCorpsTeamIdsSql})
  `))[0][0].count
}

// 钉钉活跃企业数
exports.weworkActiveTeamsCount = async (ids) => {
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users
    where id in (${ids.join(',')})
    and team_id in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 留存用户
exports.retentionUsersCount = async (since, ids) => {
  return (await sequelize.query(`
    select count(id) count
    from users
    where 1 = 1
    and id in (${ids.join(',')})
    and register_time < '${since}'
  `))[0][0].count
}

// 主站留存用户
exports.webRetentionUsersCount = async (since, ids) => {
  return (await sequelize.query(`
    select count(id) count
    from users
    where 1 = 1
    and id in (${ids.join(',')})
    and register_time < '${since}'
    and (
      team_id is null
      or (
        team_id not in (${dingtalkCorpsTeamIdsSql})
        and team_id not in (${weworkCorpsTeamIdsSql})
      )
    )
  `))[0][0].count
}

// 钉钉留存用户
exports.dingtalkRetentionUsersCount = async (since, ids) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where id in (${ids.join(',')})
    and register_time < '${since}'
    and team_id in (${dingtalkCorpsTeamIdsSql})
  `))[0][0].count
}

// 微信留存用户
exports.weworkRetentionUsersCount = async (since, ids) => {
  return (await sequelize.query(`
    select count(1) count
    from users
    where id in (${ids.join(',')})
    and register_time < '${since}'
    and team_id in (${weworkCorpsTeamIdsSql})
  `))[0][0].count
}

// 人均新增字数
exports.avgNewWords = async (since, to) => {
  let result = await his.query(`
    select revs, user_id
    from file_histories
    where created_at between '${since}' and '${to}'
  `)
  let users = []
  let newWordsCount = 0
  let reg, regResult
  for (let data of result[0]) {
    users.push(data.user_id)
    regResult = /Z:([0-9a-z]+)([><])([0-9a-z]+)/.exec(data.revs)
    if (regResult && regResult[2] == '>') {
      newWordsCount += parseInt(regResult[3], 36)
    }
  }
  return parseInt(newWordsCount / _.uniq(users).length)
}

// 新增评论数
exports.newCommentsCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from comments c
    where c.created_at between '${since}' and '${to}'
  `))[0][0].count
}

// 新增分享数
exports.newSharesCount = async (since, to) => {
  return (await sequelize.query(`
    select count(1) count
    from permissions p
    where 1 = 1
    and p.created_at between '${since}' and '${to}'
    and p.role != 'owner'
  `))[0][0].count
}

// 周常用企业数
exports.weekFrequentUsersCount = async (ids) => {
  const userIds = _(ids).groupBy().pickBy(x => x.length >= 3).keys().value()
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users u
    where u.team_id is not null
    and u.id in (${userIds.join(',')})
  `))[0][0].count
}

// 周重度企业数
exports.weekHeavyUsersCount = async (ids) => {
  const userIds = _(ids).groupBy().pickBy(x => x.length >= 5).keys().value()
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users u
    where u.team_id is not null
    and u.id in (${userIds.join(',')})
  `))[0][0].count
}

// 周钉钉常用企业数
exports.weekDingtalkFrequentUsersCount = async (ids) => {
  const userIds = _(ids).groupBy().pickBy(x => x.length >= 3).keys().value()
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users u
    where u.team_id is not null
    and u.team_id in (${dingtalkCorpsTeamIdsSql})
    and u.id in (${userIds.join(',')})
  `))[0][0].count
}

// 周钉钉重度企业数
exports.weekDingtalkHeavyUsersCount = async (ids) => {
  const userIds = _(ids).groupBy().pickBy(x => x.length >= 5).keys().value()
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users u
    where u.team_id is not null
    and u.team_id in (${dingtalkCorpsTeamIdsSql})
    and u.id in (${userIds.join(',')})
  `))[0][0].count
}

// 周企业微信常用企业数
exports.weekWeworkFrequentUsersCount = async (ids) => {
  const userIds = _(ids).groupBy().pickBy(x => x.length >= 3).keys().value()
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users u
    where u.team_id is not null
    and u.team_id in (${weworkCorpsTeamIdsSql})
    and u.id in (${userIds.join(',')})
  `))[0][0].count
}

// 周企业微信重度企业数
exports.weekWeworkHeavyUsersCount = async (ids) => {
  const userIds = _(ids).groupBy().pickBy(x => x.length >= 5).keys().value()
  return (await sequelize.query(`
    select count(distinct team_id) count
    from users u
    where u.team_id is not null
    and u.team_id in (${weworkCorpsTeamIdsSql})
    and u.id in (${userIds.join(',')})
  `))[0][0].count
}

exports.dingtalkMemberUserIdsSql = dingtalkMemberUserIdsSql
exports.dingtalkCorpsTeamIdsSql = dingtalkCorpsTeamIdsSql
exports.weworkMemberUserIdsSql = weworkMemberUserIdsSql
exports.weworkCorpsTeamIdsSql = weworkCorpsTeamIdsSql

