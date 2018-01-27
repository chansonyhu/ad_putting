import React, { Component } from 'react'
import AdMainContract from '../build/contracts/AdMain.json'
import getWeb3 from './utils/getWeb3'

import { Layout, Menu, Spin, Alert} from 'antd';

import AdBoard from './components/AdBoard';
import Advertiser from './components/Advertiser';

import 'antd/dist/antd.css';
import './App.css';

const { Header, Content, Footer } = Layout;

class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      storageValue: 0,
      web3: null,
      mode: 'adBoard'
    }
  }

  componentWillMount() {
    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.

    getWeb3.then(results => {
      this.setState({
        web3: results.web3
      })

      // Instantiate contract once web3 provided.
      this.instantiateContract()
    })
    .catch(() => {
      console.log('Error finding web3.')
    })
  }

  instantiateContract() {
    /*
     * SMART CONTRACT EXAMPLE
     *
     * Normally these functions would be called in the context of a
     * state management library, but for convenience I've placed them here.
     */

    const contract = require('truffle-contract');
    const AdMain = contract(AdMainContract);
    AdMain.setProvider(this.state.web3.currentProvider);

    // Get accounts.
    this.state.web3.eth.getAccounts((error, accounts) => {
      this.setState({
        account: accounts[0],
      });
      AdMain.deployed().then((instance) => {
        this.setState({
          adMain: instance
        });
      })
    })
    
  }

  onSelectTab = ({key}) => {
    this.setState({
      mode: key
    });
  }

  renderContent = () => {
    const { account, adMain, web3, mode } = this.state;

    if (!adMain) {
      return <Spin tip="Loading..." />;
    }

    switch(mode) {
      case 'adBoard':
        return <AdBoard account={account} adMain={adMain} web3={web3} />
      case 'advertiser':
        return <Advertiser account={account} adMain={adMain} web3={web3} />
      default:
        return <Alert message="请选一个模式" type="info" showIcon />
    }
  }

  render() {
    return (
      <Layout>
        <Header className="header">
          <div className="logo">ProChain广告演示系统</div>
          <Menu
            theme="dark"
            mode="horizontal"
            defaultSelectedKeys={['adBoard']}
            style={{ lineHeight: '64px' }}
            onSelect={this.onSelectTab}
          >
            <Menu.Item key="adBoard">广告板</Menu.Item>
            <Menu.Item key="advertiser">广告主</Menu.Item>
          </Menu>
        </Header>
        <Content style={{ padding: '0 50px' }}>
          <Layout style={{ padding: '40px 100px', background: '#fff', minHeight: '1200px' }}>
            {this.renderContent()}
          </Layout>
        </Content>
        <Footer style={{ textAlign: 'center' }}>
        </Footer>
      </Layout>
    );
  }
}

export default App
