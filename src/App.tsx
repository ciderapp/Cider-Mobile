import React, {useEffect, useState} from 'react';
import {Text, NativeModules, View} from 'react-native';
import EncryptedStorage from 'react-native-encrypted-storage';
const {AMTokenProvider} = NativeModules;

import CiderLogo from '../assets/cider-round.svg';

const fetchJson = async (url: string, headers?: any) => {
  return await fetch(url, {
    headers: headers,
  })
    .then(res => {
      return res.json();
    })
    .catch(error => {
      console.log(error);
    });
};

const App = () => {
  const [devToken, setDevToken] = useState('');
  const [usrToken, setUsrToken] = useState('');

  useEffect(() => {
    // Fetch the auth tokens
    (async () => {
      try {
        // Fetch devToken
        const fetched_devToken = await fetchJson('https://api.cider.sh/v1', {
          'user-agent': 'Cider/0.0.1',
        }).then(res => {
          return res.token;
        });
        setDevToken(fetched_devToken);

        // Fetch usrToken
        let fetched_usrToken = '';
        const stored_usrToken = await EncryptedStorage.getItem('usrToken');
        if (stored_usrToken === null) {
          console.log('No usrToken found. Fetching...');
          // Authorize user
          fetched_usrToken = await AMTokenProvider.generateUserToken(
            fetched_devToken,
          );
          EncryptedStorage.setItem('usrToken', fetched_usrToken);
        } else {
          // Verify usability of usrToken
          const library_songs = await fetchJson(
            'https://api.music.apple.com/v1/me/library/songs',
            {
              Authorization: 'Bearer ' + fetched_devToken,
              'Music-User-Token': stored_usrToken,
            },
          );
          if (library_songs.errors !== undefined) {
            console.log('usrToken is invalid. Fetching...');
            // Authorize user
            fetched_usrToken = await AMTokenProvider.generateUserToken(
              fetched_devToken,
            );
            EncryptedStorage.setItem('usrToken', fetched_usrToken);
          }

          fetched_usrToken = stored_usrToken;
        }

        setUsrToken(fetched_usrToken);
      } catch (error) {
        console.log(error);
      }
    })();
  }, []);

  return (
    <View>
      {usrToken !== '' ? (
        <Text>Hello World! Tokens Loaded!</Text>
      ) : (
        <CiderLogo />
      )}
    </View>
  );
};

export default App;
