# slashaaron.com / slash-aaron 全面方案

**状态**: review 修订版
**日期**: 2026-05-01
**核心句**: `/aaron` + 你对我说的话。我帮你把事情做完。
**仓库决策**: 新建 `slash-aaron` 作为总产品仓库；当前仓库保留为第一个专业能力包 `seo-geo`。

## 1. 结论

不要把当前 `seo-geo-claude-skills` 仓库直接改名或改造成
`slash-aaron` 总产品仓库。

正确结构是：

```text
slash-aaron                 # 总产品、官网、/aaron 入口、跨能力包路由、能力包注册表
seo-geo-claude-skills       # 第一个专业能力包：SEO/GEO
future-dev-pack             # 后续能力包：研发
future-writing-pack         # 后续能力包：写作
future-ops-pack             # 后续能力包：运营
future-research-pack        # 后续能力包：研究
```

当前仓库不是被替换，而是成为 `slash-aaron` 的 **anchor pack**：

```text
SEO/GEO capability pack for slash-aaron.
```

新 `slash-aaron` 仓库可以很薄，避免冷启动；它从第一天开始就聚合当前仓库已有的技能、命令、验证、平台证据和使用案例。但跨能力包路由、官网、unsupported/future-pack 场景、能力包 schema 和产品级 registry 必须由新仓库承担，不能反向塞进 SEO/GEO pack。

## 2. 产品定位

slashaaron.com 不是命令市场，也不是 SEO/GEO 工具站。它是一个自然语言工作入口：

```text
/aaron <tell me what you want done>
```

用户不应该先学习技能、命令、agent、工具或 workflow。用户只说目标，系统负责理解、路由、执行、检查和交付。

推荐对外 copy 必须带能力边界：

```text
Type /aaron, say the outcome.
Starts with verified SEO/GEO work, then grows by verified capability packs.
```

中文定位：

```text
/aaron + 你对我说的话。我帮你把事情做完。
从已验证的 SEO/GEO 工作开始，逐步扩展到更多已验证能力包。
```

可以保留愿景感，但公开能力声明必须和已验证的能力包绑定。任何会产生破坏性、公开性、付费性、外部副作用或不可逆后果的动作，都必须先拿到明确确认。

## 3. 为什么不直接把当前仓库改成 slash-aaron

当前仓库已经有清晰身份：

- 20 个 SEO/GEO 技能；
- 20 个 `/aaron:*` 命令；
- SEO/GEO 专业引用、评估、质量门；
- marketplace、platform、manifest、README、版本和验证脚本；
- 已积累的安装路径、支持声明和项目历史。

直接改造成 `slash-aaron` 会带来三类问题。

### 3.1 品牌边界混乱

`slash-aaron` 是总产品；`seo-geo-claude-skills` 是第一个专业能力包。把总产品塞进第一个能力包，会让后续研发、写作、运营、研究等能力接入时变得别扭。

### 3.2 发布和安装风险高

当前仓库的发布面围绕 SEO/GEO。强行改名会影响：

- README 和中文 README；
- plugin / marketplace manifest；
- 平台支持声明；
- `/aaron:` command architecture；
- 版本历史和 release notes；
- 现有用户安装心智。

这类迁移成本高，但对 MVP 没有足够收益。

### 3.3 扩展性差

未来能力包不应该都塞进这个仓库。这个仓库有 SEO/GEO 专业上下文和行数预算约束，应该保持专业、可验证、可发布。

## 4. 仓库边界

### 4.1 新仓库：`slash-aaron`

职责：

- slashaaron.com 官网；
- `/aaron` 产品入口说明；
- 第一层 capability resolver；
- capability pack schema；
- capability registry；
- 跨能力包 routing contract；
- unsupported/future-pack 场景；
- 官网示例和展示素材；
- 支持状态和验证证据的聚合视图。

不负责：

- 承载所有专业技能正文；
- 复制每个能力包的验证逻辑；
- 维护每个专业领域的深层 runbook；
- 手写第二套平台支持事实；
- 对未验证能力做公开支持声明。

### 4.2 当前仓库：`seo-geo-claude-skills`

职责：

- 作为 `slash-aaron` 的第一个成熟能力包；
- 继续维护 SEO/GEO 技能、命令、评估和质量门；
- 提供 pack-local resolver；
- 提供平台安装和支持证据；
- 在预算允许时输出最小 capability manifest 给 `slash-aaron` 聚合。

不负责：

- 选择未来 dev、writing、ops、research 能力包；
- 维护总产品官网；
- 存放 future-pack 示例；
- 存放 unsupported/future-pack eval；
- 复制 `slash-aaron` 产品级 registry；
- 承载非 SEO/GEO pack 的 runbook、validator、manifest 或 examples。

当前仓库的定位应调整为：

```text
SEO/GEO capability pack for slash-aaron.
```

不是：

```text
The whole slash-aaron product.
```

## 5. 能力包模型

`/aaron` 以后应该通过 **capability packs** 扩展，而不是不断修改用户入口。

能力包是一个边界清晰的专业域，能够把自然语言请求稳定地变成可交付成果。

### 5.1 Schema 所属

正式 schema 应由新 `slash-aaron` 仓库维护：

```text
schemas/capability-pack.schema.json
```

当前仓库如果新增 `distribution/capability-pack.json`，必须使用该 schema 的 pinned version 校验。不能只靠 prose 说明字段。

### 5.2 必填字段

每个能力包 manifest 至少必须声明：

- `schemaVersion`: manifest schema 版本；
- `packVersion`: 能力包版本；
- `id`: 能力包标识，例如 `seo-geo`；
- `name`: 展示名称；
- `product`: 所属产品，例如 `slash-aaron`；
- `repo`: 源仓库；
- `manifestPath`: manifest 在源仓库的位置；
- `resolver`: pack-local resolver 路径和类型；
- `entrypoints`: pack 默认入口和专家入口；
- `commands`: pack 内命令的稳定 ID、slash name、路径和用途；
- `skills`: pack 内技能的稳定 ID、路径和用途；
- `scope`: 支持的工作范围；
- `artifacts`: 常见交付物；
- `qualityGates`: pack-specific 质量门；
- `approvalGates`: 可执行审批门；
- `unsupportedClaims`: 明确不支持或不能公开承诺的能力；
- `validation`: 验证命令和证据；
- `distribution`: 平台支持事实的权威来源指针；
- `evidence`: 示例、验证日期和来源。

### 5.3 示例 manifest

示例是结构要求，不是最终完整 JSON：

```json
{
  "schemaVersion": "slash-aaron-capability-pack.v1",
  "packVersion": "9.9.9",
  "id": "seo-geo",
  "name": "SEO/GEO Capability Pack",
  "product": "slash-aaron",
  "repo": "https://github.com/aaron-he-zhu/seo-geo-claude-skills",
  "manifestPath": "distribution/capability-pack.json",
  "maturity": "anchor-pack",
  "resolver": {
    "type": "pack-local",
    "path": "references/skill-resolver.md",
    "scope": "seo-geo-only"
  },
  "entrypoints": {
    "default": {
      "slash": "/aaron:auto",
      "path": "commands/auto.md",
      "scope": "pack-local"
    },
    "maxDepth": {
      "slash": "/aaron:max",
      "path": "commands/max.md",
      "scope": "pack-local"
    }
  },
  "commands": [
    {
      "id": "seo-geo.audit",
      "slash": "/aaron:audit",
      "path": "commands/audit.md",
      "role": "page/content SEO and CORE-EEAT audit"
    }
  ],
  "skills": [
    {
      "id": "keyword-research",
      "path": "research/keyword-research/SKILL.md",
      "role": "keyword demand and topic opportunity research"
    }
  ],
  "scope": [
    "keyword research",
    "SEO/GEO content",
    "technical SEO",
    "AI visibility",
    "authority",
    "monitoring",
    "reporting"
  ],
  "artifacts": [
    "brief",
    "article draft",
    "audit report",
    "publish package",
    "visibility report",
    "monitoring plan"
  ],
  "qualityGates": [
    {
      "id": "core-eeat",
      "kind": "pack-specific",
      "reference": "references/core-eeat-benchmark.md"
    },
    {
      "id": "cite",
      "kind": "pack-specific",
      "reference": "references/cite-domain-rating.md"
    }
  ],
  "approvalGates": [
    {
      "id": "external_side_effect",
      "triggers": ["send outreach", "publish externally", "change production setting"],
      "defaultMode": "dry_run",
      "requiresConfirmation": {
        "action": "exact external action",
        "scope": "target accounts, URLs, recipients, or systems",
        "surface": "where the action will happen"
      },
      "nonGrantWords": ["apply", "publish", "fix", "send", "launch"],
      "logging": "record action, scope, timestamp, and approval text",
      "rollback": "state rollback or manual recovery plan before execution"
    }
  ],
  "unsupportedClaims": [
    "guaranteed rankings",
    "guaranteed AI citations",
    "autonomous CMS publishing",
    "paid outreach execution without explicit approval",
    "non-SEO/GEO professional work"
  ],
  "validation": {
    "commands": [
      "git diff --check",
      "node .github/scripts/sync-skills.js --check",
      "bash scripts/validate-skill.sh --status",
      "bash scripts/validate-slimming-guardrails.sh"
    ],
    "requiresSchemaCheck": true,
    "requiresPackageSurfaceCheck": true
  },
  "distribution": {
    "platformsSource": "distribution/platforms.json",
    "claimMode": "derive-per-host-from-source"
  },
  "evidence": {
    "examplesSource": "slash-aaron/examples/seo-geo.md",
    "lastVerified": "2026-05-01"
  }
}
```

## 6. `/aaron` 路由模型

长期路由分两层，但两层属于不同仓库。

### 6.1 第一层：Capability Resolver

所属仓库：

```text
slash-aaron
```

职责：

- 判断用户请求属于哪个能力包；
- 处理未安装、未验证或 future-pack 请求；
- 选择 pack-local entrypoint；
- 维护跨能力包 routing contract；
- 防止命令命名冲突。

示例：

```text
/aaron refresh this article for AI visibility
  -> seo-geo pack -> /aaron:auto inside seo-geo

/aaron review this pull request and fix the tests
  -> dev pack, future

/aaron turn this transcript into a publishable essay
  -> writing pack, future
```

如果没有已安装或已验证的能力包，`slash-aaron` 应明确降级：

```text
I do not have a verified capability pack for this yet. I can help draft a plan,
but I should not claim full execution support.
```

### 6.2 第二层：Pack Resolver

所属仓库：

```text
capability pack repo
```

当前仓库已有 [references/skill-resolver.md](../references/skill-resolver.md)，它只负责 SEO/GEO pack 内部路由。它不负责未来 dev、writing、ops、research pack 的选择。

### 6.3 命名空间规则

为避免多个能力包都定义 `/aaron:publish`、`/aaron:report` 或 `/aaron:auto`，需要分开两个概念：

- **product-level alias**: 用户看到的 `/aaron`、`/aaron:auto`、`/aaron:max`；
- **pack-internal command id**: registry 中的稳定 ID，例如 `seo-geo.publish`、`dev.review`、`writing.edit`。

同一 host 如果只能暴露一个 `/aaron:*` namespace，则由 `slash-aaron` 产品层决定别名映射；pack repo 只声明自身命令，不抢全局命名权。

## 7. 当前仓库需要做的调整

### 7.1 README 定位调整

英文 README 可增加一句关系说明，但不得把当前仓库写成总产品：

```text
This repository is the SEO/GEO anchor capability pack for slash-aaron.
```

中文 README 可增加：

```text
本仓库是 slash-aaron 的 SEO/GEO anchor 能力包。
```

公开链接到 `slashaaron.com` 或 `github.com/aaron-he-zhu/slash-aaron` 之前，必须确认新 repo 和网站已经存在，避免死链和过早承诺。

### 7.2 Product API 契约边界

[references/aaron-product-api-contract.md](../references/aaron-product-api-contract.md) 不应承担全局 capability selection。

当前仓库只应声明：

```text
/aaron:auto runs the SEO/GEO pack-local workflow.
Cross-pack capability selection belongs to the slash-aaron product repo.
If a request is clearly outside SEO/GEO, this pack should decline or point to
slash-aaron rather than route into a fake SEO/GEO workflow.
```

保留：

- `/aaron` 是产品心智和可选 root alias；
- `/aaron:auto` 是 SEO/GEO pack 的兼容实现入口；
- `/aaron:max` 是 SEO/GEO pack 内明确要求最大深度时才使用；
- 专家命令是 SEO/GEO pack 内部执行 API。

### 7.3 `/aaron:auto` 和 `/aaron:max` 文案调整

[commands/auto.md](../commands/auto.md) 和 [commands/max.md](../commands/max.md) 不应改成全局 pack selector。

建议改成 pack-local 表述：

```text
Run the end-to-end SEO/GEO capability-pack workflow implied by a natural-language goal,
using the smallest safe depth.
```

如果用户请求明显不属于 SEO/GEO，命令应停止并返回：

```text
This looks outside the SEO/GEO pack. Use slash-aaron product routing or install
the relevant verified capability pack before claiming full execution support.
```

### 7.4 capability manifest

新增 `distribution/capability-pack.json` 之前，必须同时满足：

1. 已有 schema：`slash-aaron/schemas/capability-pack.schema.json`。
2. 当前仓库有 pinned schema version 或可重复的 schema validation command。
3. `bash scripts/validate-slimming-guardrails.sh` 检查 manifest 存在、JSON 有效、schema 通过。
4. CI workflow 监听 `distribution/capability-pack.json` 和相关 schema/check 脚本。
5. package surface 明确：该 manifest 是有意随 public bundle 发布，或被明确排除。
6. 当前仓库 counted-line budget 有净空。

注意：平台支持声明仍由以下文件单独管理：

```text
distribution/platforms.json
```

`capability-pack.json` 只能引用或派生平台支持事实，不能手写第二套 verified claim。

### 7.5 官网示例素材

不要在当前仓库新增 counted public docs，例如：

```text
docs/slash-aaron-examples.md
```

理由：

- 当前仓库 counted-line budget 已经非常紧；
- 官网示例属于产品层；
- future-pack examples 不应进入 SEO/GEO pack。

示例素材应放在新仓库：

```text
slash-aaron/examples/seo-geo.md
```

该文件可以引用当前仓库的命令、技能和验证证据，但不复制深层 runbook。

### 7.6 unsupported/future-pack 场景

不要把 non-SEO/GEO、future-pack 或 unsupported cases 直接塞进当前
[evals/product-api-scenarios.md](../evals/product-api-scenarios.md)。

原因：

- 现有 parser 要求真实 `target_skill`；
- 现有 cases 期望当前 `/aaron:*` route；
- 直接加入 unsupported cases 会导致 fake route 或 guardrail 失败。

这类场景应放在新仓库：

```text
slash-aaron/evals/capability-routing-scenarios.md
```

只有在当前 repo 明确扩展 eval schema，并且 guardrail 支持 unsupported-case 类型后，才可以把 pack-local unsupported behavior 放进当前 repo。

### 7.7 行数预算

当前 repo 的实施必须满足：

- 所有进入 `distribution/`、`docs/`、`evals/`、`references/`、`commands/`、README 的新增内容都计入预算；
- 当前 repo anchor-pack PR 必须是 **net counted lines <= 0**，除非先有明确 slimming PR；
- 如果新增 `distribution/capability-pack.json`，必须通过删除、压缩或迁移其他 counted content 释放足够预算；
- `.docs/` 可以承载方案讨论，但不能替代 release-bearing manifest 或 validation。

## 8. 新 `slash-aaron` 仓库应该长什么样

第一版保持薄壳：

```text
slash-aaron/
  README.md
  AGENTS.md
  product/
    vision.md
    routing-contract.md
    capability-pack-contract.md
    approval-gates.md
  schemas/
    capability-pack.schema.json
  registry/
    capabilities.json
  evals/
    capability-routing-scenarios.md
  examples/
    seo-geo.md
  website/
    ...
```

不要新增 `registry/platforms.json` 作为第二个平台事实源。平台支持状态必须从各 pack 的平台 registry 派生。

### 8.1 `registry/capabilities.json`

聚合能力包，不复制能力包内部所有细节，不手写 per-host verified claim：

```json
{
  "schema": "slash-aaron-capabilities.v1",
  "capabilities": [
    {
      "id": "seo-geo",
      "name": "SEO/GEO",
      "repo": "https://github.com/aaron-he-zhu/seo-geo-claude-skills",
      "manifest": "distribution/capability-pack.json",
      "schemaVersion": "slash-aaron-capability-pack.v1",
      "status": "anchor-pack",
      "routing": {
        "resolver": "pack-local",
        "defaultEntrypoint": "/aaron:auto"
      },
      "supportClaims": {
        "mode": "derived",
        "source": "distribution/platforms.json"
      }
    }
  ]
}
```

### 8.2 `product/routing-contract.md`

定义跨能力包路由：

```text
User request -> capability resolver -> pack resolver -> execution -> review -> delivery
```

### 8.3 `product/approval-gates.md`

定义所有 pack 必须遵守的审批语义：

- 默认 dry-run；
- 必须说明 action、scope、surface；
- 必须展示即将执行的外部副作用；
- 必须记录确认文本；
- 必须说明 rollback 或 recovery；
- `apply`、`publish`、`send`、`fix`、`launch` 等普通动词不自动构成授权。

### 8.4 `website/`

slashaaron.com 第一屏可以是 `/aaron` 输入体验，但必须露出当前边界：

```text
slashaaron.com

/aaron + what you say.
Starting with verified SEO/GEO work.

[/aaron describe the SEO/GEO thing you want done...]
```

如果网站第一版只是 prompt composer、安装入口或 demo，而不是托管执行器，首屏必须明确表达，避免用户误以为网页本身会执行所有工作。

## 9. MVP 范围

第一版公开承诺：

```text
/aaron gets the first class of professional work from request to deliverable,
starting with verified SEO/GEO growth workflows.
```

MVP 包含：

- `/aaron` 产品定位；
- `/aaron:auto` 作为 SEO/GEO pack 的兼容入口；
- SEO/GEO anchor pack；
- capability schema；
- capability registry；
- 官网首页或 prompt composer；
- 5-10 个 SEO/GEO 展示示例，放在新 `slash-aaron` repo；
- 支持声明和验证证据链接；
- unsupported/future-pack 的安全降级规则。

MVP 不包含：

- 所有专业工作的完整自动化；
- 自动执行外部账号操作；
- 自动发布或付费 outreach；
- 未验证 host 的支持声明；
- 未成熟能力包的公开营销承诺；
- 把所有未来能力塞进当前仓库；
- 把网页第一版伪装成全自动执行器。

## 10. 实施路线

### Phase 0: 修订方案

先完成本文档修订，确保所有 review findings 被吸收。

### Phase 1: 新建 `slash-aaron` 薄仓库

先在新仓库建立产品层，避免污染当前 SEO/GEO pack：

1. README 说明 `/aaron` 产品愿景和当前边界。
2. 增加 `schemas/capability-pack.schema.json`。
3. 增加 `registry/capabilities.json`。
4. 引用当前仓库作为第一个 anchor pack。
5. 增加 `product/routing-contract.md`。
6. 增加 `product/approval-gates.md`。
7. 增加 `evals/capability-routing-scenarios.md`。
8. 增加 `examples/seo-geo.md`。
9. 放官网或 prompt composer 骨架。

### Phase 2: 当前仓库最小 anchor-pack PR

当前仓库只做最小可验证接入：

1. README / 中文 README 增加 SEO/GEO anchor pack 关系说明。
2. `references/aaron-product-api-contract.md` 明确 pack-local 边界，不承担 global resolver。
3. `commands/auto.md` 和 `commands/max.md` 只做 pack-local copy 修正，不改成跨包选择器。
4. 如需新增 `distribution/capability-pack.json`，必须先满足 schema、CI、package surface、line-budget 条件。
5. 不新增 `docs/slash-aaron-examples.md`。
6. 不把 unsupported/future-pack eval 塞进当前 parser。

Phase 2 必须净控制 counted lines。若无法做到 net counted lines <= 0，先做 slimming PR。

### Phase 3: Manifest 接入

只有在 Phase 1 schema 已存在且当前仓库有预算后，才新增：

```text
distribution/capability-pack.json
```

同时必须新增或更新：

- schema validation command；
- guardrail check；
- workflow watch；
- package surface expectation；
- `distribution/platforms.json` 派生规则；
- exact validation command list。

### Phase 4: slashaaron.com 首屏

上线一个非常窄的可用站：

1. 第一屏是 `/aaron` 输入体验或 prompt composer。
2. 首屏明确写出 `Starting with verified SEO/GEO work`。
3. 下方展示 SEO/GEO pack 的真实工作样例。
4. 安装入口指向当前仓库的验证安装方式。
5. 支持声明只展示从 `distribution/platforms.json` 派生的 host 状态。
6. 未支持能力明确标注为 future pack 或 unsupported。

### Phase 5: 第二能力包接入

当出现第二个成熟领域，例如 dev、writing、ops、research，再按 capability pack contract 接入。

接入前必须有：

- manifest；
- schema validation；
- examples；
- pack-local resolver；
- pack-specific quality gates；
- approval gates；
- validation commands；
- evidence links；
- unsupportedClaims；
- platform support source 或明确无 platform support；
- product-level routing scenarios。

## 11. 验收标准

当前仓库调整完成后，应满足：

- README 明确说明它是 `slash-aaron` 的 SEO/GEO anchor capability pack；
- `/aaron:auto` 契约只负责 SEO/GEO pack-local 路由；
- cross-pack capability resolver 不在当前仓库；
- SEO/GEO pack 仍然保留 20 个技能和 20 个命令；
- 平台支持声明仍由 `distribution/platforms.json` 管理；
- 如存在 `distribution/capability-pack.json`，必须通过 schema、guardrail、CI 和 package surface 校验；
- 未验证能力不会被写成公开支持声明；
- 当前 repo anchor PR 满足 line-budget；
- 现有 guardrail 和技能验证通过。

新 `slash-aaron` 仓库完成后，应满足：

- 新用户只需要理解 `/aaron`；
- 第一个能力包不是空白占位，而是链接到成熟 SEO/GEO pack；
- registry 能说明当前支持什么、不支持什么；
- registry 不复制 per-host platform truth；
- slashaaron.com 能展示真实可交付成果；
- unsupported/future-pack requests 有单独验收场景；
- 新能力包可以按同一 schema 接入。

## 12. 验证命令

当前仓库任何 release-bearing 改动至少运行：

```bash
git diff --check
node .github/scripts/sync-skills.js --check
bash scripts/validate-skill.sh --status
bash scripts/validate-slimming-guardrails.sh
```

如果新增 `distribution/capability-pack.json`，还必须运行：

```bash
jq -e . distribution/capability-pack.json
# plus schema validation using the pinned slash-aaron capability-pack schema
# plus package-surface validation once the repo defines exact package expectations
```

对应 CI 必须监听：

```text
distribution/capability-pack.json
schemas or schema-version lock file
scripts that validate capability-pack manifests
.github/workflows/*
```

## 13. 风险和边界

| 风险 | 处理方式 |
|------|----------|
| 新 repo 冷启动 | 让当前仓库作为 anchor pack，提供技能、命令、示例和验证证据 |
| 当前 repo 被总产品污染 | 当前 repo 只做 SEO/GEO pack，不承载 global resolver 或 future packs |
| `/aaron` 被误解为万能 | 公共 copy 有愿景，但首屏必须写明 starting with verified SEO/GEO work |
| host 不支持 root `/aaron` | `/aaron` 是产品心智；`/aaron:auto` 是兼容实现 |
| 平台支持和能力支持混淆 | `platforms.json` 管平台；`capability-pack.json` 管能力；新 repo 只派生 |
| 未来能力包质量不齐 | 每个 pack 必须有 schema-validated manifest、examples、quality gates、approval gates 和 evidence |
| 行数预算被压爆 | 当前 repo 只做最小 anchor-pack 声明；产品总层、examples、unsupported eval 放到新 repo |
| approval gates 变成口号 | 用对象化 gate 定义 trigger、confirmation、scope、logging 和 rollback |

## 14. 一句话北极星

```text
/aaron is the work button for Aaron's agent system.
```

当前仓库的北极星：

```text
seo-geo-claude-skills is the first verified capability pack behind /aaron.
```

新仓库的北极星：

```text
slash-aaron is the product layer that turns /aaron requests into routed,
verified capability-pack execution.
```
