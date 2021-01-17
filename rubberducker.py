import librosa
import soundfile
import os, glob, pickle
import numpy as np
import firebase_admin
import google.cloud
import pickle5 as pickle
from firebase import Firebase
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score
from librosa.core import istft
from firebase_admin import credentials, initialize_app, storage, firestore, db




def extract_feature(file_name, mfcc, chroma, mel):
    with soundfile.SoundFile(file_name) as sound_file:
        X = sound_file.read(dtype="float32")
        sample_rate=sound_file.samplerate
        if chroma:
            stft = np.abs(librosa.stft(X))
        result = np.array([])
        if mfcc:
            mfccs = np.mean(librosa.feature.mfcc(y=X, sr=sample_rate, n_mfcc=40).T, axis=0)
            result = np.hstack((result, mfccs))
        if chroma:
            chroma = np.mean(librosa.feature.chroma_stft(S=stft, sr=sample_rate).T,axis=0)
            result = np.hstack((result, chroma))
    if mel:
        mel = np.mean(librosa.feature.melspectrogram(X, sr=sample_rate).T,axis=0)
        result=np.hstack((result, mel))
    return result



#load date for sound file
def load_own() :
    for file in glob.glob('C:\\Projects\\RubberDuck\\speech-emotion-recognition-ravdess-data\\num25\\audiofile.wav'):
        feature = extract_feature(file, mfcc=True, chroma=True, mel=True)
        return feature
# 03-01-08-02-02-02-01

# Init firebase with your credentials
cred = credentials.Certificate('C:\\Projects\\RubberDuck\\rubberduckfinal\\rubberduck-65f9c-firebase-adminsdk-u5jsw-bc574695d4.json')
initialize_app(cred, {'storageBucket': 'rubberduck-65f9c.appspot.com'})

# Put your local file path 
#fileName = 'C:\\Projects\\RubberDuck\\speech-emotion-recognition-ravdess-data\\num25\\audiofile.wav'
#bucket = storage.bucket()
#blob = bucket.blob(fileName)
#blob.upload_from_filename(fileName)
config = {"apiKey":"AIzaSyBqEF41l5P_hMo3lkupd8YiJhwPpT3ew4o",
 "authDomain":"rubberduck-65f9c.firebaseapp.com",
 "databaseURL":"https://rubberduck-65f9c-default-rtdb.firebaseio.com",
 "storageBucket":"rubberduck-65f9c.appspot.com"
}

firebase = Firebase(config)

storage = firebase.storage()
storage.child("audiofile.wav").download('C:\\Projects\\RubberDuck\\speech-emotion-recognition-ravdess-data\\num25\\audiofile.wav')


#make data usable
ownFeature = [load_own()]
#ownUsable = ownFeature.reshape(1, -1)
#print (loadedModel)
#print (ownFeature)
#load model
modelName = 'C:\\Projects\\RubberDuck\\rubberduckfinal\\rubberduckalg.sav'
loadedModel = pickle.load(open(modelName, 'rb'))

ownSound = loadedModel.predict(ownFeature)
print(ownSound)

db = firebase_admin.initialize_app(cred, {'databaseURL': 'https://rubberduck-65f9c.firebaseio.com/'}, 'secondary')

# ref = db.collection(u'results').document(u'emotion')
ref = firestore.client()


#box_ref = ref.child('emotion')

print (ownSound[0])

temp = ref.collection(u'results').document(u'emotion')
temp.update({'type': ownSound[0]})


