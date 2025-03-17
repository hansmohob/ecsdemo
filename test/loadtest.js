import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 50,
  duration: '5m',
};

export default function () {
  const BASE_URL = 'http://REPLACE'; //Replace with ALB address similar to http://stacknamealbdvcatsanddogs-1234567890.eu-west-2.elb.amazonaws.com
  
  http.get(`${BASE_URL}/`);     // web frontend
  http.get(`${BASE_URL}/cats`); // cats service
  http.get(`${BASE_URL}/dogs`); // dogs service
  sleep(0.5);
}