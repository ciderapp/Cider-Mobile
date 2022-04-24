import React, {useEffect, useState} from 'react';
import {Text} from 'react-native';

const FetchDevToken = async () => {
  const json = await fetch('https://api.cider.sh/v1', {
    headers: {
      'user-agent': 'Cider/0.0.1',
    },
  })
    .then(res => {
      return res.json();
    })
    .catch(error => {
      console.log(error);
    });
  return await json.token;
};

const App = () => {
  const [devToken, setDevToken] = useState('');

  useEffect(() => {
    (async () => {
      setDevToken(await FetchDevToken());
    })();
  }, []);

  return (
    <Text>
      {devToken !== '' ? (
        <Text>Hello World! you cock suckers. token {devToken}</Text>
      ) : (
        <Text>Hello World! you cock suckers.</Text>
      )}
    </Text>
  );
};

export default App;
