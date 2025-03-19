import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 300,
  duration: '5m',
  thresholds: {
    http_req_failed: ['rate<0.01'], // Error rate < 1%
    http_req_duration: ['p(95)<500'] // 95% of requests should be below 500ms
  },
};

export default function () {
  const BASE_URL = 'http://REPLACE_ME'; //Replace with ALB DNS name similar to http://stacknamealbdvcatsanddogs-1234567890.eu-west-2.elb.amazonaws.com  

  http.get(`${BASE_URL}/`);     // web frontend
  http.get(`${BASE_URL}/cats`); // cats service
  http.get(`${BASE_URL}/dogs`); // dogs service
  sleep(0.1);
}