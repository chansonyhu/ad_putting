import React, { Component } from 'react'
import { Layout, Carousel } from 'antd';

import AdContractContract from '../../build/contracts/AdContract.json'

const { Content, Spin } = Layout;

class AdBoard extends Component {
    constructor(props) {
        super(props);
    }

    componentDidMount() {
        const { account, adMain, web3, adContracts} = this.props;
        const that = this;
        var URLs = [], counter = 0;
        adContracts.forEach(function (contract, index) {
            contract.getURL({
                from: account,
            }).then((result) => {
                URLs[counter++] = result;
                if (URLs.length = adContracts.length) {
                    that.setState({URLs: URLs});
                }
            });
        })
    }

    clickAd = (index, linkURL, event) => {
        const { account, adContracts, mediaAddr} = this.props;
        event.preventDefault();
        event.stopPropagation();

        const abiDecoder = require('abi-decoder');
        abiDecoder.addABI(AdContractContract.abi);
        adContracts[index].adClick(mediaAddr, {
            from: account
        }).then((e) => {
            // const decodedLogs = abiDecoder.decodeLogs(e.receipt.logs);
            // console.log(decodedLogs);
            // web3.eth.getTransactionReceipt("0x9199e262aaab0a6ec99558b3e9f42397c07a2bb9c6befb637643aebfb03cc32a", function(e, receipt) {
            //     const decodedLogs = abiDecoder.decodeLogs(receipt.logs);
            // });
            console.log(e);
            window.location = linkURL;
        }).catch((err) => {
            console.error(err);
        });
    }

    render() {

        // var URLs = [{imageURL: "https://img.alicdn.com/tfs/TB1KGAnolDH8KJjSspnXXbNAVXa-1125-350.jpg", linkURL: "https://world.taobao.com/"}, {imageURL: "https://img.alicdn.com/tfs/TB1KGAnolDH8KJjSspnXXbNAVXa-1125-350.jpg", linkURL: "https://world.taobao.com/"}];
        const { adContracts, account} = this.props;
        const that = this;
        if (!(this.state && this.state.URLs)) {
            return (
                <Layout style={{ padding: '24px 0', background: '#fff' }}>
                    <Content >
                    </Content>
                </Layout>
            );
        } else {
            var items = [];
        
            this.state.URLs.forEach((URL, i) => {
                items.push(<div className="item" key={i}><img key={i} src={URL[0]} onClick={that.clickAd.bind(this, i, URL[1])}/></div>);
            });
            return (
                <Layout style={{ padding: '24px 0', background: '#fff' }}>
                    <Content >
                        <Carousel autoplay>
                            {items}
                        </Carousel>
                    </Content>
                </Layout>
            );
        }
    }
}

export default AdBoard