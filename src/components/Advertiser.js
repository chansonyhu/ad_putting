import React, { Component } from 'react'
import { Layout } from 'antd';

class Advertiser extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
  }


  renderContent() {

    return (
      <div>
      </div>
    );
  }

  render() {
    const { account, adMain, web3 } = this.props;

    return (
      <Layout style={{ padding: '0 0', background: '#fff' }}>
        <h2>广告主信息</h2>
        {this.renderContent()}
      </Layout >
    );
  }
}

export default Advertiser
