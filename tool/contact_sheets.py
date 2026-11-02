from PIL import Image, ImageDraw
from pathlib import Path
p=Path('docs/design')
groups=[['splash','onboarding-1','onboarding-2','onboarding-3','sign-up','sign-in'],['forgot-password','forgot-password-verification-code','forgot-password-set-new-password','forgot-password-success','account-setup-confirmation-code','account-setup-profile'],['account-setup-complete-profile','account-setup-interest','account-setup-find-friends','home-v1','home-v3','home-video'],['comment','notification','discover-search','post-photo','post-photo-filter','post-photo-edit'],['post-gallery','message','live-watch-live','story','account-user-profile','account-settings']]
for i,names in enumerate(groups):
 out=Image.new('RGB',(1284,950),'#333333');d=ImageDraw.Draw(out)
 for j,n in enumerate(names):
  im=Image.open(p/(n+'.png')).resize((214,463)); x=(j%6)*214
  out.paste(im,(x,25));d.text((x+4,5),n,fill='white')
 out.crop((0,0,1284,490)).save(p/f'overview-{i}.jpg')
