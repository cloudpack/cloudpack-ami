# cloudpack-ami
## AMIのありか

(2018年12月05日現在)

| Distribution | 名称 | AMI ID |
|:---:|:---|:---|
| CentOS7 | cloudpack-ami CentOS7 1543986071 | ami-0969852476aa3ec35 |
| CentOS6 | cloudpack-ami CentOS6 1537421247 | ami-03c942fd0222bdd1f |

いずれもログインユーザーは `cloudpack` です。

## cloudpack-amiとは何か

ISOから素の状態に近いAMIをフルスクラッチで作成します。
https://github.com/shiguredo/packer-templates こちらを大いに参考とさせていただきました。
2017年10月8日よりSWAPを廃止しました。必要な方は適宜ご用意下さい。

### 基本方針

- 可能な限り公式に提供されているISOをもとにして構成します。
- SR-IOV / ENA driver / irqbalance などは初期状態で組み込みます。(CentOS6はSR-IOV非対応)
- bashの `SYSLOG_HISTORY` に対応します。
- ログインユーザーは `cloudpack` となります(sudo可)。

### 取り込んでいるもの(予定含む)

- sysctl / limits まわりの既定値の変更
- 構成時点において `yum -y update` を実施
- ログインユーザーは cloudpack(パスワード同じ)
- HVM対応インスタンスのみ選択可能
- ENA対応カーネルモジュール
- ixgbevf対応カーネルモジュール
- bash `SYSLOG_HISTORY` への対応

## cloudpack-amiの作り方

以下の手続きを行うことでAMI作成手続きを実行します。
- 公式ISOの取得とsha256確認
- kickstartによる構成
- kickstartにて作成されたベースに最低限の構成
- 作成したVMDKをS3へアップロード
- アップロードしたVMDKからAMIへ変換の指示

```
cd %OSNAME%
./iso2ami.sh -B %YOUR_S3_BUCKET_NAME% -P %PREFIX%
```

しばらくするとAMIがimportされてAMI IDが発行されます。
そのAMI_IDを用いて最終調整を行います。
AMI_IDを自動認識し、packerにて処理を進めます。

### 必要な要素

- AWSアカウント
- S3バケット(ImportImageを実施するため)
- [Packer](https://www.packer.io)
- [VirtualBox](https://www.virtualbox.org)
- [Vagrant](https://www.vagrantup.com)
- [AWS CLI](https://github.com/aws/aws-cli)
- 上記が利用できる環境(当方OSXで実装)


## ToDo

- 今のところなし

## 今後のメモ

```
sed -i.bak -e 's:\(.*\)ixgbevf.conf\(.*\):#\1ixgbevf.conf\2:g' ec2-utils.spec
rpm --without upstart ec2-utils.spec
```
