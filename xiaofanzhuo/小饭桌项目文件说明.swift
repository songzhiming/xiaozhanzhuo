//
//  小饭桌项目文件说明.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/27.
//  Copyright (c) 2015年 陈鲲鹏. All rights reserved.
//

/**
- 项目用到的第三方库：
    SDWebImage.其中SDWebImage是以Frameworks导进项目的。
    网络库Alamofire为了适配ios7，把源文件单独抽了出来放在了Utils->Http文件夹下，不然没法上传app store。
    FMDB：用于保存草稿，在utils->Persistent文件夹里面

    以下第三方库在Utils->ThirdParty文件安家里面
    讯飞语音：我不知道放在哪里。。
    友盟统计，友盟分享，友盟第三方登录（已废弃）：
    百度推送：
    MJRefresh：
*/

/*
- 主要文件夹：顺序按程序启动页面先后顺序从下排列到上

*************************************************************************************************************
-- Utils:包含各种工具
------Classes：用于打印alloc,dealloc的Debug信息的一个根类，所有VC的根类
------PlaceFlie：注册页面选择城市的城市Json文件
------Persistent：保存各种发布页面的草稿信息的一个Manager,对第三方库fmdb的封装
------MulSelectAlbum：自定义的一个本地多选相册
------font：小饭桌主要字体，方正兰亭
------HolderTextView：自定义的一个带placeHolder的UITextView,
------Alert：头顶上出现的小黑带提示，ProgressHud为原本的第三方提示，后来有问题不用了，现在作为适配器使用
------Loading：不解释
------BlurView：夜色项目拿过来的2个Objc类，用于个人信息编辑页面兴趣和行业选择时出现的全屏截图模糊背景
------CommonTools：用于项目的公用工具类，包含oc工具，swift工具
------Http:包含项目用到的url，Alamofrie网络库源文件，Reachability因为重名随便改了一个，HttpManager是封装了Alamofire的一个类
------BasicViewController：所有vc的次根类，继承了AllocDeallocViewController，包含自定义的Navigation(headView),ExtraView(很多页面右下角的蓝色按钮，如社区的发布话题按钮)
------ExtraView：蓝色发布按钮
------HeadView：顶部的自定义navigation
------ApplicationContext：增加或者获取当前登录用户的id，信息等工具
------GlobalVarAndExtension：全局变量，String的MD5加密Extension，UIWindow的顶部提示框Extension，UIView角标Extension
------NavigationPopGestureDelagate:右滑Pop的手势delegate，用于限制某几个VC不响应右滑手势

*************************************************************************************************************

-- LoginViewController：登录注册的页面
------Views:GuideView:程序初次启动的时候的导航页；RefreshView:Appdelegate刷不出主页时候的页面
------LoginViewControllerNew：程序登录注册
------RegisterViewController：注册
------SignInViewController：登录
------ResetPasswordViewController：重置密码
*************************************************************************************************************

-- SignUp：个人信息填写页面
------Views：MoreInfomationView，用于展示行业与兴趣
------NewUpdatePages：2个信息填写的页面
------VerifyViewController：审核页面

*************************************************************************************************************

-- HomeViewController：社区，重磅，组队，我的 四个VC的parentVC
------BasePublicController:所有发布页面的根VC,有语音输入，相册选择，@用户功能
------Model：上传照片，@用户，搜索用户 所对应的model
------View: BasePublicController下面的已选照片

*************************************************************************************************************

-- ArticleViewController：重磅相关
------Models：页面数据相关Model，包括列表，头图，评论
------RefactorArticleViewController:重磅页VC
------Second:二级页面，文件夹里面包含了3级页面以及评论页
------TitleImageNewsView 与 TitleAritcleHeadView 组成了重磅页焦点图

*************************************************************************************************************

-- CommunityViewController：社区相关
------Models:社区数据相关model
------Views：话题详情，发言详情的tableHeaderView
------CommunityViewController:社区首页
------TopicDetailViewController：话题详情
------PersonCommentViewController：发言详情
------SendNewTopicViewController：发起新话题
------SendNewReplyViewController：新发言
------SendNewCommentViewController：新评论
------EditMyTopicDetailViewController：编辑话题
------EditMyReplyDetailViewController：编辑发言

*************************************************************************************************************

-- MakeUpTouchViewController：和社区类似的组队
------Views：组队详情的tableHeader
------second:组队详情，组队评论发布页面
------MakeUpTouchViewController：组队首页
------SendNewMakeUpViewController：新组队
------EditMyMakpViewController：编辑组队

*************************************************************************************************************

-- PersonalCenterViewController ：我的，个人中心
------PersonalCenterViewController：个人中心首页
------second：二级页面，分别是，关于小饭桌-我收藏的话题-我的发言-我发起的话题-个人设置-我参与的组队-我发起的组队-个人积分-消息-福利

*************************************************************************************************************

-- RecommendViewController：首页左上角推荐按钮出来的页面
------这块不熟，没出过什么问题，比较稳定，包含了推荐项目，推荐会员注册

*************************************************************************************************************

-- OtherInfoView：ta人详情

*************************************************************************************************************

-- SearchView：首页右上角的搜索按钮

*************************************************************************************************************

-- ZoomView： 点开浏览大图的组件

*************************************************************************************************************
*/

/*
- 一些问题：
 HomeViewController 第77行，viewWithTag有时候会返回空值，程序开发4个多月只是最近出现过一次
 HeaderView: 开发初期没有处理好，导致非常臃肿难以修改，不过现在很稳定
- 联系方式：qq：674027158 陈鲲鹏
*/
