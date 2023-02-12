import '../css/style.scss'
import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import GUI from "lil-gui";
import vertexSource from "./shader/vertexShader.glsl";
import fragmentSource from "./shader/fragmentShader.glsl";

import img from '../images/image.jpg';

class Main {
  constructor() {
    this.viewport = {
      width: window.innerWidth,
      height: window.innerHeight
    };

    this.canvas = document.querySelector("#canvas");
    this.renderer = null;
    this.scene = new THREE.Scene();
    this.camera = null;
    this.cameraFov = 45;
    this.cameraFovRadian = (this.cameraFov / 2) * (Math.PI / 180);
    this.cameraDistance = (this.viewport.height / 2) / Math.tan(this.cameraFovRadian);
    this.controls = null;
    this.gui = new GUI();
    this.geometry = null;
    this.cubeGeometry = null;
    this.material = null;
    this.mesh = null;
    this.cubeMesh = null;

    this.uniforms = {
      uTime: {
        value: 0.0
      },
      uTimeSpeed: {
        value: 0.5
      },
      uTex: {
        value: this.texture
      },
      uResolution: {
        value: new THREE.Vector2(this.viewport.width, this.viewport.height)
      },
      uTexResolution: {
        value: new THREE.Vector2(2048, 1024)
      },
      uNoiseLoudness: {
        value: 1.0
      }
    };

    this.clock = new THREE.Clock();

    this.init();
    // this._init();
    // this._update();
    // this._addEvent();
  }

  _setRenderer() {
    this.renderer = new THREE.WebGLRenderer({
      canvas: this.canvas,
      alpha: true
    });
    this.renderer.setPixelRatio(window.devicePixelRatio);
    this.renderer.setSize(this.viewport.width, this.viewport.height);
  }

  _setCamera() {
    // this.camera = new THREE.PerspectiveCamera(45, this.viewport.width / this.viewport.height, 1, 100);
    // this.camera.position.set(0, 0, 5);
    // this.scene.add(this.camera);

    //ウインドウとWebGL座標を一致させる
    // const fov = 45;
    // const fovRadian = (fov / 2) * (Math.PI / 180); //視野角をラジアンに変換
    // const distance = (this.viewport.height / 2) / Math.tan(fovRadian); //ウインドウぴったりのカメラ距離
    this.camera = new THREE.PerspectiveCamera(this.cameraFov, this.viewport.width / this.viewport.height, 1, this.cameraDistance * 2);
    this.camera.position.z = this.cameraDistance;
    this.camera.lookAt(new THREE.Vector3(0, 0, 0));
    this.scene.add(this.camera);
  }

  _setGui() {
    this.gui.add(this.uniforms.uNoiseLoudness, 'value').min(0.0).max(50.0).step(0.2).name('ノイズの粒度')
    this.gui.add(this.uniforms.uTimeSpeed, 'value').min(0.001).max(5.0).step(0.001).name('速さ')
  }

  _setControlls() {
    this.controls = new OrbitControls(this.camera, this.canvas);
    this.controls.enableDamping = true;
  }

  _setLight() {
    const light = new THREE.DirectionalLight(0xffffff, 1.5);
    light.position.set(1, 1, 1);
    this.scene.add(light);
  }

  _addMesh() {
    //ジオメトリ
    this.geometry = new THREE.PlaneGeometry(this.viewport.width, this.viewport.height, 40, 40);
    this.cubeGeometry = new THREE.SphereGeometry(200, 40, 40);

    //テクスチャ
    const loader = new THREE.TextureLoader();
    this.uniforms.uTex.value = loader.load(img);

    console.log(this.texture);

    //マテリアル
    this.material = new THREE.ShaderMaterial({
      uniforms: this.uniforms,
      vertexShader: vertexSource,
      fragmentShader: fragmentSource,
      side: THREE.DoubleSide
    });

    //メッシュ
    this.mesh = new THREE.Mesh(this.geometry, this.material);
    this.scene.add(this.mesh);

    this.cubeMesh = new THREE.Mesh(this.cubeGeometry, this.material);
    this.cubeMesh.position.z += 300;
    this.scene.add(this.cubeMesh);
  }

  init() {
    this._setRenderer();
    this._setCamera();
    this._setGui();
    this._setControlls();
    this._setLight();
    this._addMesh();

    this._update();
    this._addEvent();
  }

  _update() {
    const elapsedTime = this.clock.getElapsedTime();
    this.uniforms.uTime.value = elapsedTime * 0.5;

    //レンダリング
    this.renderer.render(this.scene, this.camera);
    this.controls.update();
    requestAnimationFrame(this._update.bind(this));
  }

  _onResize() {
    this.viewport = {
      width: window.innerWidth,
      height: window.innerHeight
    }
    // レンダラーのサイズを修正
    this.renderer.setSize(this.viewport.width, this.viewport.height);
    // カメラのアスペクト比を修正
    this.camera.aspect = this.viewport.width / this.viewport.height;
    this.camera.updateProjectionMatrix();
    // カメラの位置を調整
    this.cameraDistance = (this.viewport.height / 2) / Math.tan(this.cameraFovRadian); //ウインドウぴったりのカメラ距離
    this.camera.position.z = this.cameraDistance;
    // uniforms変数に反映
    this.mesh.material.uniforms.uResolution.value.set(this.viewport.width, this.viewport.height);
    // meshのscale設定
    const scaleX = Math.round(this.viewport.width / this.mesh.geometry.parameters.width * 100) / 100 + 0.01;
    const scaleY = Math.round(this.viewport.height / this.mesh.geometry.parameters.height * 100) / 100 + 0.01;
    this.mesh.scale.set(scaleX, scaleY, 1);
  }

  _addEvent() {
    window.addEventListener("resize", this._onResize.bind(this));
  }
}

const main = new Main();
