# GitLab代码审查流程

---

## 1. 相关分支说明

### Master

该分支就是主分支的意思。在git repo下主分支的职责主要就是负责记录stable版本的迭代，当开发版本的项目得到了充分的验证之后，才能将分支并入master分支。master分支永远是production-ready的状态，即稳定可产品化发布的状态。

### dev

这个分支就是我们平常开发的一个主要分支了，不管是要做新的feature还是需要做bug fix，都是从这个分支checkout来做。在这个分支下主要负责记录开发状态下相对稳定的版本，即完成了某个feature或者修复了某个bug后的开发稳定版本。

### Feature branches

这是由许多分别负责不同feature开发的分支组成的一个分支系列。new feature主要就在这些分支系列下进行开发。当我们在一个大的develop的迭代之下，往往我们会把每一个迭代分成很多个功能点，并将功能点分派给不同人的人员去开发。每一个人员开发的功能点就会形成一个feature分支，当功能点开发测试完毕之后，就会合并到develop分支去。

### test

这个分支系列从dev分支出来，也就是测试分支。在测试状态下，如果出现缺陷，那么就从该test分支拉出新分支进行修复，修复完毕测试通过后，即分别并入master分支和dev分支，随后master分支做正常发布。

### Hotfix branches

这个分支系列也就是我们常说的紧急线上修复，当线上出现bug且特别紧急的时候，就可以从master拉出分支到这里进行修复，修复完成后分别并入master和develop分支。

下面这张图是git workflow的最佳实践。

实际运用到我们公司，因为需要代码review和持续发布，所以取消了release branches，增加了tev分支。

![gitlab workflow](img/110657_00nE_1781981.jpg)

## 2. 工作流程

### 2.1 新建分支

当我们需要开发一个新功能时，或修复一个bug时，首先从dev分支拉出一个新的分支，命名可以类似feature_1，或bug_1。数字可以是jira中的issue号码。

```
$ git checkout dev
$ git checkout -v feature_1
```

### 2.2 提交代码

在分支开发完成后，将本地的`feature_1`分支push到gitlab服务器上。

### 2.3 提交合并请求

我们完成的工作需要提交到项目的主要分支上，所以需要在gitlab上新建一个`feature_1`分支合并到`dev`分支的请求：

![create MR](img/20161008174354.png)

选择合并的源分支和目标分支：

![create MR](img/20161008174809.png)

编辑MR详细信息，并确认创建合并请求：
![create MR](img/2016100814786.png)

### 2.4 审查代码

代码审查人员有三种途径链接到需要审查的MR：

1. 通过邮件中的链接
2. 登录gitlab，通过Todos中心进入
3. 进入项目，点击`Merge Requests`标签，在列表中选择`Merge Request`

![create MR](img/20161009105111.png)

* 讨论决议

`Discussion resolution`可以帮助我们跟踪审查代码的进展。解决意见防止我们忘记处理反馈并隐藏了不再相关的讨论。
![create MR](img/20161009111152.png)


## 3. Q&A

### 1. Q：线上的或者测试环境出现bug，开发人员在修复bug时，应该是一个怎样的工作流？

我们的工作流和codeview流程并没有限制代码片段一定是`feature_1(bug_1)`->`dev`->`test`->`master`的流向。

相反，git可以让我们更加灵活的应用branch和merge来优化我们的工作流程。

当我们的测试环境或线上环境出现bug需要修复时，开发人员应当直接从`test`或`master`分支检出一个新的`bugfix`分支来开发代码，bug修复后，通过本文[第二部分](#2-工作流程)的方法，提交从当前`bugfix`分支到`test`或`master`分支的合并请求。Codeviewer通过后，合并代码，我们的持续集成（CI）组件会将新的代码发布到相应的测试环境或生产环境。然后测试bug是否被修复。

那么，我们在test或master分支上fix bug产生的代码片段，如何提交到dev分支上呢。如下图，我们可以在已合并的MR页面点击`Cherry-pick`，将代码应用到`dev`分支：

![](img/20161101182352.png)

**此流程将更加敏捷的修复各种环境中的bug**，而不是将修复bug的代码提交到dev分支，然后再通过各种业务或行政流程来发布到测试环境或生产环境。