import json,re
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
root=Path('.')
frames=json.loads(Path('docs/design/frames.json').read_text(encoding='utf-8'))
routes={'Splash':'splash','Onboarding 1':'onboarding','Onboarding 2':'onboarding-2','Onboarding 3':'onboarding-3','Sign up':'sign-up','Sign in':'sign-in','Forgot Password':'recovery','Forgot Password - Verification Code':'reset-code','Forgot Password - Set New Password':'new-password','Forgot Password - Success':'password-success','Account Setup - Confirmation Code':'confirmation','Account Setup - Profile':'setup-name','Account Setup - Complete Profile':'complete-profile','Account Setup - Interest':'interests','Account Setup - Find Friends':'find-friends','Home V1':'home','Home V2':'home-v2','Home V3':'home-v3','Home - Video':'video','Live - Watch Live':'live','Story':'story','Comment':'comments','Notification':'notifications','Discover':'discover','Discover - Search':'search','Post - Photo':'camera','Post - Photo - Filter':'filter','Post - Photo - Edit':'edit','Post - Photo - Share':'share','Post - Gallery':'gallery','Message':'messages','Message - Chat':'chat','Message - Video Call':'call','Account - Profile':'profile','Account - User Profile':'user','Account - Settings':'settings'}
lines=['# Pixso 原稿与 Flutter 页面对应表','','设计文件：Balb - Social Media App UI Kit。原稿基准尺寸为 428 × 926。50 个画板对应 36 个业务页面/样式及 14 个输入状态；另补充话题、收藏、编辑资料、设置详情和帖子详情。','','输入和完成状态由同一表单实现。表中截图为 Flutter 实现；原稿链接是从 Pixso 导出的参考图。系统输入法属于设备，渲染截图不包含原稿里绘制的 iOS 键盘。','','| 原稿画板 | Pixso 节点 | 路由 | 实现截图 | 原稿 |','| --- | --- | --- | --- | --- |']
for f in sorted(frames,key=lambda x:(x['bounds']['y'],x['bounds']['x'])):
 name=f['name'];base=name;state=''
 for suffix in [' - Typing',' - Active']:
  if base.endswith(suffix):base=base[:-len(suffix)];state='-'+suffix[3:].lower()
 route=routes[base];shot=route+state;original=re.sub('[^a-z0-9]+','-',name.lower())
 assert Path(f'docs/screenshots/{shot}.png').exists(),shot
 lines.append(f"| {name} | `{f['id']}` | `/{route}` | [查看](screenshots/{shot}.png) | [参考](design/{original}.png) |")
lines+=['','## 其他设计页分类','','`⚙️ Design System`：Typography System、Color Palette、Icons、Components。已用于统一字体、深色表面、青色按钮、输入框、头像、分段标签及导航。Material Icons 为原稿线框图标的对应实现。','','`🖼 Preview`：Figma Thumbnail、Poduct Card、Hero、Preview 1–8、Full Preview，共 12 个展示画板，是同一套 App 的封面与排版预览，不是新增的 App 业务页面。']
Path('docs/PAGE_MAP.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
groups={
'引导与账号':['splash','onboarding','onboarding-2','onboarding-3','sign-up','sign-in','recovery','reset-code','new-password','password-success','confirmation','setup-name','complete-profile','interests','find-friends'],
'动态与发现':['home','home-v2','home-v3','video','live','story','comments','notifications','discover','search','topics','topic-travel','post-detail'],
'发布流程':['camera','gallery','filter','edit','share','published-post'],
'消息与个人中心':['messages','chat','chat-sent','call','profile','user','edit-profile','saved','saved-populated'],
'设置':['settings','settings-privacy','settings-notification','settings-security','settings-language','settings-help','settings-about-us'],
'真实表单状态':[r+'-'+state for r in ['sign-up','sign-in','recovery','reset-code','new-password','confirmation','setup-name'] for state in ['typing','active']]}
shots=[p for p in Path('docs/screenshots').glob('*.png') if p.name!='overview.png'];assert len(shots)==64,len(shots)
lines=['# 界面截图目录','','共 **64 张单独界面截图**，由 `tool/capture_screens_test.dart` 使用 Flutter 测试渲染器生成，尺寸均为 **428 × 926**。预加载原项目字体、Material 图标与全部图片后再截图；不是把 Pixso 页面当作实现截图。另提供一张主要页面概览。','','原稿 50 张参考图位于 `design/`，逐页对应关系见 [PAGE_MAP.md](PAGE_MAP.md)。本批截图不含设备系统状态栏与系统键盘；Typing 展示真实焦点与内容，Active 展示填写完成后的状态。Android 模拟器因磁盘空间耗尽掉线，当前未将本批截图标为模拟器截图。','','![主要页面概览](screenshots/overview.png)','']
for title,names in groups.items():
 lines += ['## '+title,'','| 页面 / 状态 | 图片 |','| --- | --- |']
 for n in names:lines.append(f'| {n} | [打开截图](screenshots/{n}.png) |')
 lines.append('')
lines+=['## 重新生成','','```powershell','flutter test tool/capture_screens_test.dart --update-goldens','```','','具有可用 Android 设备时，也可使用设备脚本：','','```powershell','flutter drive --driver=test_driver/screenshots.dart --target=integration_test/app_test.dart -d emulator-5554','```','']
Path('docs/SCREENSHOTS.md').write_text('\n'.join(lines),encoding='utf-8')
names=['home','discover','profile','chat','filter','share'];w=280;h=606
board=Image.new('RGB',(w*3+80,h*2+122),'#101616');draw=ImageDraw.Draw(board)
font=ImageFont.truetype('assets/fonts/Poppins-SemiBold.ttf',17)
for i,n in enumerate(names):
 x=20+(i%3)*(w+20);y=40+(i//3)*(h+42);im=Image.open(f'docs/screenshots/{n}.png').convert('RGB').resize((w,h),Image.Resampling.LANCZOS);board.paste(im,(x,y));draw.text((x,y-28),n.upper(),fill='#c0eded',font=font)
board.save('docs/screenshots/overview.png')
p=Path('docs/design/assets.json');a=json.loads(p.read_text());a=[v for v in a if v['file']!='assets/images/video.png'];a.append({'file':'assets/images/video.png','nodeId':'80:7347'});p.write_text(json.dumps(a,indent=2)+'\n')
print({'source_frames':len(frames),'base_design_pages':len(routes),'screenshots':len(shots),'assets':len(a)})
