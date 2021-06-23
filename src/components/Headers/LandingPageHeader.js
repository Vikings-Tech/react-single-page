/*!

=========================================================
* Paper Kit React - v1.3.0
=========================================================

* Product Page: https://www.creative-tim.com/product/paper-kit-react

* Copyright 2021 Creative Tim (https://www.creative-tim.com)
* Licensed under MIT (https://github.com/creativetimofficial/paper-kit-react/blob/main/LICENSE.md)

* Coded by Creative Tim

=========================================================

* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

*/
import React from "react";

// reactstrap components
import { Button, Card, Form, Input, Container, Row, Col } from "reactstrap";
import NotificationAlert from "react-notification-alert";



// core components

function LandingPageHeader() {
  let pageHeader = React.createRef();
  const notificationAlert = React.useRef();

  React.useEffect(() => {
    if (window.innerWidth < 991) {
      const updateScroll = () => {
        let windowScrollTop = window.pageYOffset / 3;
        pageHeader.current.style.transform =
          "translate3d(0," + windowScrollTop + "px,0)";
      };
      window.addEventListener("scroll", updateScroll);
      return function cleanup() {
        window.removeEventListener("scroll", updateScroll);
      };
    }
  });

  return (
    <>
      <NotificationAlert ref={notificationAlert} />

      <div
        style={{
          backgroundImage:
            "url(" + require("assets/img/daniel-olahh.jpg").default + ")",
        }}
        className="page-header"
        data-parallax={true}
        ref={pageHeader}
      >
        <Row className="ml-auto mr-auto">
          <div className="motto text-center" style={{ width: "100%" }}>
            <h1>Example page</h1>
            <h3>Start designing your landing page here.</h3>
            <br />
            <br />
          </div>
        </Row>
        <Row className="justify-content-center">
        <Button className="btn-round text-center" color="danger" onClick={() => {
          let options = {
            place: "tr",
            message: (
              <div>
                <div>
                 Something to show
                </div>
              </div>
            ),
            type: "danger",
            icon: "nc-icon nc-bell-55",
            autoDismiss: 10,
          };
          notificationAlert.current.notificationAlert(options);
        }}>
          Click me
          </Button>
          </Row>
      </div>
    </>
  );
}

export default LandingPageHeader;
