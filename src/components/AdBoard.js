import React, { Component } from 'react'
import { Layout, Carousel } from 'antd';

const { Content } = Layout;

class AdBoard extends Component {
    constructor(props) {
        super(props);
    }

    componentDidMount() {
        const { account, adMain } = this.props;
        adMain.owner.call({
            from: account
        }).then((result) => {
            this.setState({
                owner: result
            });
        })
    }

    renderContent = () => {
    }

    clickAd = () => {
        console.log('clickAd');
    }

    render() {
        var URLs = [{imageURL: "https://img.alicdn.com/tfs/TB1KGAnolDH8KJjSspnXXbNAVXa-1125-350.jpg", linkURL: "https://world.taobao.com/"}, {imageURL: "https://img.alicdn.com/tfs/TB1KGAnolDH8KJjSspnXXbNAVXa-1125-350.jpg", linkURL: "https://world.taobao.com/"}];
        var that = this;
        return (
            <Layout style={{ padding: '24px 0', background: '#fff' }}>
                <Content >
                    <Carousel autoplay>
                        {
                            URLs.map(function (item) {
                                return <div className="item" onClick={that.clickAd}>
                                    <img src={item.imageURL} />
                                    </div>
                            })
                        }
                    </Carousel>
                </Content>
            </Layout>
        );
    }
}

export default AdBoard