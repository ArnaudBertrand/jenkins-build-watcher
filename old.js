// const notifier = require('node-notifier');

const smile = 'http://jcpintegration.nce.amadeus.net/job/ddslh/job/lufthansa-nui-lh/job/releases/job/major-smileABC/job/official/';
const cash_and_miles = 'http://jcpintegration.nce.amadeus.net/job/ddslh/job/lufthansa-nui-lh/job/releases/job/cash_and_miles/job/official/';

const finished = [];
const inProgress = [];

function getJob(url) {
  // const url = `http://jcpintegration.nce.amadeus.net/job/ddslh/job/lufthansa-nui-lh/job/releases/job/major-smileABC/job/${id}`;
  let chunks = '';
  fetch(`${url}api/json`).then(res => res.json()).then(({building, id, result}) => {
      if (!building && inProgress.indexOf(id) > -1) {
        console.log('Job finished: %s, with status: %s', id, result);
        // notifier.notify({
        //   title: 'Job finished',
        //   message: `Job ${id} finished with status ${result}`,
        // });
      }

      if (building && inProgress.indexOf(id) === -1) {
        console.log('Job building: %s', id);
        inProgress.push(id);
      }

      // Keep finished builds to not call them again
      if (!building) {
        finished.push(id);
      }
    })
}

setInterval(() => {
  const url = `${cash_and_miles}api/json`;
  fetch(url).then(res => res.json()).then(data => {
    data.builds.forEach(({id, url}) => {
      // If job are finished don't call them again
      if (finished.indexOf(id) === -1) { getJob(url); }
    });
  });
}, 15000);
