from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive

gauth = GoogleAuth()
gauth.LocalWebserverAuth()
drive = GoogleDrive(gauth) # Create GoogleDrive instance with authenticated GoogleAuth instance

allImages = []
allFolders = []
bp="webimages"

alist = drive.ListFile({'q': "title= '%s' "  % bp}).GetList()
def ListFolder(parent):
    file_list = drive.ListFile({'q': "'%s' in parents and trashed=false" % parent}).GetList()
    for f in file_list:
        print 'title: %s' % f['title']
        if f['mimeType']=='application/vnd.google-apps.folder': # if folder
            allFolders.append(f)
            ListFolder(f['id'])
        else:
            allImages.append(f)
ListFolder(alist[0]['id'])

d2 = {}
d2[alist[0]['id']]=[bp,"0"]  ### change this to get URL names for files in a particular folder

for a in allFolders:
    pid = a['id']
    d2[pid] = [ a['title'], a['parents'][0]['id']]

f2 = []
for a in allImages:
    title = a['title']
    url = a[u'webContentLink']
    pid = a['parents'][0]['id']
    f2.append(    [title, url, d2[pid][0]])

import csv
with open("/tmp/images.csv", 'wb') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    heads = ['title','url','parent']
    spamwriter.writerow(heads)
    for r in  f2:
        spamwriter.writerow(r)
csvfile.close()

